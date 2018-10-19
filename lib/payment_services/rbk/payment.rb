require_relative 'client'

class PaymentServices::RBK
  class Payment < ApplicationRecord
    include Workflow
    self.table_name = 'rbk_money_payments'

    scope :ordered, -> { order(id: :desc) }

    register_currency :rub
    monetize :amount_in_cents, as: :amount, with_currency: :rub
    validates :amount_in_cents, :rbk_id, :rbk_invoice_id, :state, presence: true

    belongs_to :invoice, class_name: 'PaymentServices::RBK::Invoice', foreign_key: :rbk_invoice_id, primary_key: :rbk_invoice_id

    workflow_column :state
    workflow do
      state :pending do
        event :success, transitions_to: :succeed
        event :fail, transitions_to: :failed
      end

      state :succeed do
        on_entry do
          invoice.pay!
        end
      end
      state :failed do
        on_entry do
          invoice.cancel!
        end
      end
    end

    def self.rbk_state_to_state(rbk_state)
      def convert_rbk_state(rbk_state)
        if Client::PAYMENT_SUCCESS_STATES.include?(rbk_state)
          :success
        elsif Client::PAYMENT_FAIL_STATES.include?(rbk_state)
          :fail
        elsif Client::PAYMENT_PENDING_STATES.include?(rbk_state)
          :pending
        else
          raise("Такого статуса не существует: #{rbk_state}")
        end
      end
    end
  end
end
