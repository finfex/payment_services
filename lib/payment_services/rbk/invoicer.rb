# frozen_string_literal: true

# Copyright (c) 2018 FINFEX https://github.com/finfex

require_relative 'invoice'
require_relative 'client'
require_relative 'customer'

class PaymentServices::RBK
  class Invoicer < ::PaymentServices::Base::Invoicer
    def create_invoice(money)
      response = Client.new.create_invoice(order_id: order.public_id, amount: money.cents)
      Invoice.create!(
        amount: money.to_f,
        order_public_id: order.public_id,
        rbk_invoice_id: response['invoice']['id'],
        payload: response
      )
    end

    def pay_invoice_url
      uri = URI.parse(PaymentServices::RBK::CHECKOUT_URL)
      invoice = PaymentServices::RBK::Invoice.find_by!(order_public_id: order.public_id)
      query_hash = {
        invoiceID: invoice.rbk_invoice_id,
        invoiceAccessToken: invoice.access_payment_token,
        name: I18n.t('payment_systems.default_company', order_id: order.public_id),
        description: I18n.t('payment_systems.default_product', order_id: order.public_id),
        bankCard: true,
        applePay: false,
        googlePay: false,
        samsungPay: false,
        amount: invoice.amount_in_cents,
        locale: 'auto'
      }

      # NOTE не используется дефолтный to_query, т.к. он кодирует пробелы в +, а нам нужно %20
      uri.query = query_hash
                  .collect { |key, value| "#{key}=#{ERB::Util.url_encode(value.to_s)}" }
                  .sort * '&'

      uri
    end
  end
end
