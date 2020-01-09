# frozen_string_literal: true

# Copyright (c) 2018 FINFEX https://github.com/finfex

require_relative 'invoice'
require_relative 'client'

class PaymentServices::AliKassa
  class Invoicer < ::PaymentServices::Base::Invoicer
    ALIKASSA_PAYMENT_FORM_URL = 'https://sci.alikassa.com/payment'
    ALIKASSA_RUB_CURRENCY = 'RUB'
    ALIKASSA_TIME_LIMIT = 18.minute.to_i
    ALIKASSA_QIWI = 'Qiwi'
    ALIKASSA_LOCALHOST_IP = '127.0.0.1'

    def create_invoice(money)
      invoice = Invoice.create!(amount: money, order_public_id: order.public_id)
      client = PaymentServices::AliKassa::Client.new(
        merchant_id: order.income_wallet.merchant_id,
        secret: order.income_wallet.api_key
      )
      deposit = client.create_deposit(
        amount: order.invoice_money.to_f,
        public_id: order.public_id,
        payment_system: ALIKASSA_QIWI,
        currency: ALIKASSA_RUB_CURRENCY,
        ip: ip_from(order.user),
        phone: order.income_account
      )
      invoice.update!(deposit_payload: deposit, pay_url: deposit.dig('return', 'payData', 'url'))
      invoice
    end

    def invoice_form_data
      description = I18n.t('payment_systems.personal_payment', order_id: order.public_id)
      {
        url: ALIKASSA_PAYMENT_FORM_URL,
        method: 'POST',
        target: '_blank',
        'accept-charset' => 'UTF-8',
        inputs: {
          merchantUuid: order.income_wallet.account,
          orderId: order.public_id,
          amount: order.invoice_money.to_f,
          currency: ALIKASSA_RUB_CURRENCY,
          desc: description,
          lifetime: ALIKASSA_TIME_LIMIT
        }
      }
    end

    def pay_invoice_url
      Invoice.find_by(order_public_id: order.public_id)&.pay_url
    end

    private

    def ip_from(user)
      if user.last_login_from_ip_address.present?
        user.last_login_from_ip_address
      elsif user.last_ip.present?
        user.last_ip
      else
        ALIKASSA_LOCALHOST_IP
      end
    end
  end
end
