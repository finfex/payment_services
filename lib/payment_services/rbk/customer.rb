require_relative 'client'
require_relative 'payment_card'

class PaymentServices::RBK
  class Customer < ApplicationRecord
    include Workflow
    self.table_name = 'rbk_money_customers'
    RBK_STATUS_SUCCESS = 'ready'

    scope :ordered, -> { order(id: :desc) }

    validates :user_id, :rbk_id, presence: true
    belongs_to :user
    has_many :payment_cards, class_name: 'PaymentServices::RBK::PaymentCard', foreign_key: :rbk_customer_id, dependent: :destroy

    workflow_column :state
    workflow do
      state :unvefified do
        event :start, transitions_to: :processing
      end
      state :processing do
        event :success, transitions_to: :verified
        event :fail, transition_to: :failed
      end
      state :verified
      state :failed
    end

    def access_token
      payload['customerAccessToken']['payload']
    end

    def bind_payment_card_url
      uri = URI.parse(PaymentServices::RBK::CHECKOUT_URL)
      uri.query = {
        customerID: rbk_id,
        customerAccessToken: access_token,
        name: I18n.t('payment_systems.default_company'),
        description: I18n.t('payment_systems.bind_card_product')
      }.to_query

      uri
    end

    def get_status
      Client.new.customer_status(self)
    end

    def rbk_events
      Client.new.customer_events(self)
    end

    def self.create_in_rbk!(user)
      response = Client.new.create_customer(user)
      create!(
        user_id: user.id,
        rbk_id: response['customer']['id'],
        payload: response
      )
    end
  end
end
