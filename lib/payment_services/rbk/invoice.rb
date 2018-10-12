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

    def order
      Order.find_by(public_id: order_public_id) || PreliminaryOrder.find_by(public_id: order_public_id)
    end

    def access_payment_token
      payload['invoiceAccessToken']['payload']
    end
  end
end
