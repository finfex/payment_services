# frozen_string_literal: true

# Copyright (c) 2019 FINFEX https://github.com/finfex

require_relative 'invoice'

class PaymentServices::AliKassaPeerToPeer
  class Invoicer < ::PaymentServices::Base::Invoicer
    ALIKASSA_PAYMENT_FORM_URL = 'https://sci.alikassa.com/payment'
    ALIKASSA_RUB_CURRENCY = 'RUB'
    ALIKASSA_CARD = 'Card'

    def create_invoice(money)
      Invoice.create!(amount: money, order_public_id: order.public_id)
    end

    def invoice_form_data
      description = I18n.t('payment_systems.personal_payment', order_id: order.public_id)
      {
        url: ALIKASSA_PAYMENT_FORM_URL,
        method: 'POST',
        target: '_blank',
        'accept-charset' => 'UTF-8',
        inputs: {
          merchantUuid: order.income_wallet.merchant_id,
          orderId: order.public_id,
          amount: order.invoice_money.to_f,
          currency: ALIKASSA_RUB_CURRENCY,
          payWayVia: ALIKASSA_CARD,
          desc: description
        }
      }
    end
  end
end
