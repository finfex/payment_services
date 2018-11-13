require_relative 'client'

class PaymentServices::RBK
  class Customer < ApplicationRecord
    include Workflow
    self.table_name = 'rbk_money_customers'
    RBK_STATUS_SUCCESS = 'ready'

    scope :ordered, -> { order(id: :desc) }

    validates :user_id, :rbk_id, presence: true
    belongs_to :user

    workflow_column :state
    workflow do
      state :card_pending do
        event :success, transitions_to: :card_binded
        event :fail, transitions_to: :card_bind_error
      end

      state :card_binded
      state :card_bind_error
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

    def update_binding_information(card_details:, status:)
      update!(binded_card: card_details)
      success! if status == RBK_STATUS_SUCCESS
    end

    def actualise_status
      response = Client.new.customer_status(self)
      success! if response['status'] == RBK_STATUS_SUCCESS
    end

    def self.create_using_api!(user)
      response = Client.new.create_customer(user)
      create!(
        user_id: user.id,
        rbk_id: response['customer']['id'],
        payload: response
      )
    end
  end
end
