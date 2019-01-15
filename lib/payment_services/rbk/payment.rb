# frozen_string_literal: true

# Copyright (c) 2018 FINFEX https://github.com/finfex

require_relative 'payment_client'

class PaymentServices::RBK
  class Payment < ApplicationRecord
    include Workflow
    self.table_name = 'rbk_money_payments'

    scope :ordered, -> { order(id: :desc) }

    register_currency :rub
    monetize :amount_in_cents, as: :amount, with_currency: :rub
    validates :amount_in_cents, :rbk_id, :rbk_invoice_id, :state, presence: true

    belongs_to :invoice,
               class_name: 'PaymentServices::RBK::Invoice',
               foreign_key: :rbk_invoice_id,
               primary_key: :rbk_invoice_id

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
        event :refund, transitions_to: :refunded
      end
      state :failed do
        on_entry do
          invoice.cancel!
        end
      end
      state :refunded
    end

    def self.rbk_state_to_state(rbk_state)
      if PaymentClient::SUCCESS_STATES.include?(rbk_state)
        :success
      elsif PaymentClient::FAIL_STATES.include?(rbk_state)
        :fail
      elsif PaymentClient::PENDING_STATES.include?(rbk_state)
        :pending
      elsif PaymentClient::REFUND_STATES.include?(rbk_state)
        :fefunded
      else
        raise("Такого статуса не существует: #{rbk_state}")
      end
    end

    def refund!
      response = PaymentClient.new.refund(self)
      update!(payload: response)
      refund!
    end
  end
end
