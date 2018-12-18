require_relative 'client'
require_relative 'payment_card'
require 'jwt'

class PaymentServices::RBK
  class Customer < ApplicationRecord
    self.table_name = 'rbk_money_customers'

    belongs_to :user
    has_many :payment_cards, class_name: 'PaymentServices::RBK::PaymentCard', foreign_key: :rbk_customer_id, dependent: :destroy

    scope :ordered, -> { order(id: :desc) }

    validates :user_id, :rbk_id, presence: true

    # TODO Выделить в команды
    def self.create_in_rbk!(user)
      response = Client.new.create_customer(user)
      access_token = response['customerAccessToken']['payload']
      create!(
        user_id: user.id,
        rbk_id: response['customer']['id'],
        access_token: access_token,
        access_token_expired_at: expiration_time_from(access_token),
        payload: response
      )
    end

    def self.expiration_time_from(token)
      token_data = JWT.decode(token, nil, false).first
      Time.at(token_data['exp'])
    end

    def bind_payment_card_url
      refresh_token! unless access_token_valid?

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

    def refresh_token!
      response = Client.new.get_token(self)
      update!(
        access_token: response['payload'],
        access_token_expired_at: self.class.expiration_time_from(response['payload'])
      )
    end

    def access_token_valid?
      access_token_expired_at.present? && access_token_expired_at > Time.zone.now
    end

    def create_payment_card!(card_data:)
      card_details = card_data.dig(:paymentResource, :paymentToolDetails)
      payment_cards.create!(
        rbk_id:      card_data[:id],
        bin:         card_details[:bin],
        last_digits: card_details[:lastDigits],
        brand:       card_details[:paymentSystem],
        card_type:   (card_details[:tokenProvider] || :bank_card),
        payload:     card_data
      )
    end
  end
end
