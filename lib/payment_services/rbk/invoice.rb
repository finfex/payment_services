# frozen_string_literal: true

# Copyright (c) 2018 FINFEX https://github.com/finfex

require_relative 'payment'
require_relative 'invoice_client'

class PaymentServices::RBK
  class Invoice < ApplicationRecord
    include Workflow
    self.table_name = 'rbk_money_invoices'

    scope :ordered, -> { order(id: :desc) }

    register_currency :rub
    monetize :amount_in_cents, as: :amount, with_currency: :rub
    validates :amount_in_cents, :order_public_id, :state, presence: true

    workflow_column :state
    workflow do
      state :pending do
        event :pay, transitions_to: :paid
        event :cancel, transitions_to: :cancelled
      end

      state :paid do
        on_entry do
          order.auto_confirm!(income_amount: amount)
        end
      end
      state :cancelled
    end

    # FIXME: в приложение
    def order
      Order.find_by(public_id: order_public_id) || PreliminaryOrder.find_by(public_id: order_public_id)
    end

    def access_payment_token
      payload['invoiceAccessToken']['payload']
    end

    def make_payment(customer)
      response = InvoiceClient.new.pay_invoice_by_customer(customer: customer, invoice: self)
      create_payment!(response)
    end

    def refund!
      response = InvoiceClient.new.get_payments(self)
      payments = response.each { |payment_json| create_payment!(payment_json) }
      payments.each(&:refund!)
    end

    private

    def create_payment!(payment_json)
      Payment.create!(
        rbk_id: payment_json['id'],
        rbk_invoice_id: rbk_invoice_id,
        amount_in_cents: payment_json['amount'],
        state: Payment.rbk_state_to_state(payment_json['status']),
        payload: payment_json
      )
    end
  end
end
