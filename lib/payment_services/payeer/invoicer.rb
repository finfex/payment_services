# Copyright (c) 2018 FINFEX <danil@brandymint.ru>

require_relative 'invoice'

class PaymentServices::Payeer
  class Invoicer < ::PaymentServices::Base::Invoicer
    PAYEER_URL  = 'https://payeer.com/merchant/'

    def create_invoice money
      Invoice.create!(amount: money, order_public_id: order.public_id)
    end

    def pay_invoice_url
      invoice = Invoice.find_by!(order_public_id: order.public_id)

      payment_data = {
        amount: sprintf('%.2f',invoice.amount.to_f),
        currency: invoice.amount.currency_as_string,
        description: Base64.strict_encode64(I18n.t('payment_systems.default_product', order_id: order.public_id))
      }

      sign_array = [
        order.income_wallet.merchant_id,
        order.public_id,
        payment_data[:amount],
        payment_data[:currency],
        payment_data[:description],
        order.income_wallet.api_key
      ]
      signature = Digest::SHA256.hexdigest(sign_array.join(':')).upcase

      uri = URI.parse(PAYEER_URL)
      uri.query = {
        m_shop: order.income_wallet.merchant_id,
        m_orderid: order.public_id,
        m_amount: payment_data[:amount],
        m_curr: payment_data[:currency],
        m_desc: payment_data[:description],
        m_sign: signature
      }.to_query
      uri
    end
  end
end
