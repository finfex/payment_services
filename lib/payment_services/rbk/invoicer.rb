require_relative 'invoice'
require_relative 'client'

class PaymentServices::RBK
  class Invoicer < ::PaymentServices::Base::Invoicer
    def create_invoice( money )
      invoice = Invoice.create!(amount: money.to_f, order_public_id: order.public_id)
      invoice_data = Client.new.create_invoice(invoice)
      invoice.update_attributes!(rbk_invoice_id: invoice_data[:id], payload: invoice_data[:payload] )
      invoice
    end
  end
end
