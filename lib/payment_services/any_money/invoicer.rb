# frozen_string_literal: true

# Copyright (c) 2018 FINFEX https://github.com/finfex

require_relative 'invoice'

class PaymentServices::AnyMoney
  class Invoicer < ::PaymentServices::Base::Invoicer
    ANYMONEY_PAYMENT_FORM_URL = 'https://sci.any.money/invoice'
    ANYMONEY_CURRENCY = 'UAH'
    ANYMONEY_PAYMENT_CARD = 'visamc'
    ANYMONEY_TIME_LIMIT = 18.minute.to_i

    def create_invoice(money)
      Invoice.create!(amount: money, order_public_id: order.public_id)
    end

    def invoice_form_data
      description = I18n.t('payment_systems.personal_payment', order_id: order.public_id)
      form_params = {
        merchant: order.income_wallet.account,
        externalid: order.public_id,
        amount: order.invoice_money.to_f,
        in_curr: ANYMONEY_CURRENCY,
        desc: description,
        expiry: ANYMONEY_TIME_LIMIT,
        payway: ANYMONEY_PAYMENT_CARD,
        callback_url: order.income_payment_system.callback_url
      }
      {
        url: ANYMONEY_PAYMENT_FORM_URL,
        method: 'POST',
        target: '_blank',
        'accept-charset' => 'UTF-8',
        inputs: form_params.merge(sign: build_signature(form_params))
      }
    end

    def build_signature(params)
      sign_string = params.sort_by { |k, _v| k }.map(&:last).join.downcase
      OpenSSL::HMAC.hexdigest("SHA512", order.income_wallet.api_key, sign_string)
    end
  end
end
