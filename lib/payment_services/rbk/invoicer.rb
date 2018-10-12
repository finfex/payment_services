require_relative 'invoice'
require_relative 'client'

class PaymentServices::RBK
  class Invoicer < ::PaymentServices::Base::Invoicer
    def create_invoice(money)
      invoice_data = Client.new.create_invoice(order_id: order.public_id, amount: money.cents)
      Invoice.create!(
        amount: money.to_f,
        order_public_id: order.public_id,
        rbk_invoice_id: invoice_data[:id],
        payload: invoice_data[:payload]
      )
    end

    def pay_invoice_url
      uri = URI.parse("https://checkout.rbk.money/v1/checkout.html")
      invoice = PaymentServices::RBK::Invoice.find_by!(order_public_id: order.public_id)
      uri.query = {
        invoiceTemplateID: invoice.rbk_invoice_id,
        invoiceTemplateAccessToken: invoice.access_payment_token,
        name: I18n.t('payment_systems.default_company', order_id: order.public_id),
        description: I18n.t('payment_systems.default_product', order_id: order.public_id),
        bankCard: true,
        applePay: false,
        googlePay: false,
        samsungPay: false,
        amount: invoice.amount_in_cents,
        popupMode: true,
        locale: 'auto'
      }.to_query

      uri
    end
  end
end
