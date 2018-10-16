class PaymentServices::RBK
  class Customer < ApplicationRecord
    include Workflow
    self.table_name = 'rbk_money_customers'

    scope :ordered, -> { order(id: :desc) }

    validates :user_id, :rbk_id, presence: true

    workflow_column :state
    workflow do
      state :pending do
        event :accept, transitions_to: :accepted
        event :reject, transitions_to: :rejected
      end

      state :accepted
      state :rejected
    end

    def access_token
      payload['invoiceAccessToken']['payload']
    end
  end
end
