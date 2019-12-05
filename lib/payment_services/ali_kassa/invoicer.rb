# frozen_string_literal: true

# Copyright (c) 2018 FINFEX https://github.com/finfex

require_relative 'invoice'

class PaymentServices::AliKassa
  class Invoicer < ::PaymentServices::Base::Invoicer
    ALIKASSA_PAYMENT_FORM_URL = 'https://sci.alikassa.com/payment'
    ALIKASSA_CURRENCY = 'RUB'
    ALIKASSA_TIME_LIMIT = 18.minute.to_i

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
          merchantUuid: order.income_wallet.account,
          orderId: order.public_id,
          amount: order.invoice_money.to_f,
          currency: ALIKASSA_CURRENCY,
          desc: description,
          lifetime: ALIKASSA_TIME_LIMIT
        }
      }
    end
  end
end
