# frozen_string_literal: true

# Copyright (c) 2019 FINFEX https://github.com/finfex

require_relative 'invoice'

class PaymentServices::AliKassaPeerToPeer
  class Invoicer < ::PaymentServices::Base::Invoicer
    ALIKASSA_PAYMENT_FORM_URL = 'https://sci.alikassa.com/payment'
    ALIKASSA_RUB_CURRENCY = 'RUB'
    ALIKASSA_CARD = 'card'

    def create_invoice(money)
      Invoice.create!(amount: money, order_public_id: order.public_id)
    end

    def invoice_form_data
      invoice_data = {
        url: ALIKASSA_PAYMENT_FORM_URL,
        method: 'POST',
        target: '_blank',
        'accept-charset' => 'UTF-8',
        inputs: {
          merchantUuid: order.income_wallet.merchant_id,
          orderId: order.public_id,
          amount: order.invoice_money.to_f,
          currency: ALIKASSA_RUB_CURRENCY,
          payWayVia: order.income_payment_system.payway&.capitalize,
          desc: I18n.t('payment_systems.default_product', order_id: order.public_id),
          customerEmail: order.user.try(:email)
        }
      }
      invoice_data[:inputs][:number] = order.income_account.gsub(/\D/, '') if order.income_payment_system.payway == ALIKASSA_CARD
      invoice_data
    end
  end
end
