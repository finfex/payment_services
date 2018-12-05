require_relative 'client'
require_relative 'customer'

class PaymentServices::RBK
  class PaymentCard < ApplicationRecord
    self.table_name = 'rbk_payment_cards'

    enum card_type: %i(bank_card applepay googlepay), _prefix: :card_type

    belongs_to :rbk_customer, class_name: 'PaymentServices::RBK::Customer', foreign_key: :rbk_customer_id

    def self.fetch_cards_for(customer: )
      raw_cards = Client.new.customer_bindings(customer)
      raw_cards.each do |raw_card|
        payment_card = customer.payment_cards.find_by(rbk_id: raw_card['id'])
        create_for_customer(customer: customer, card_data: raw_card) unless payment_card
      end
    end

    def self.create_for_customer(customer: , card_data:)
      card_data.deep_symbolize_keys!
      card_details = card_data.dig(:paymentResource, :paymentToolDetails)
      customer.payment_cards.create!(
        rbk_id: card_data[:id],
        bin: card_details[:bin],
        last_digits: card_details[:lastDigits],
        brand: card_details[:paymentSystem],
        card_type: (card_details[:tokenProvider] || :bank_card),
        payload: card_data
      )
    end
  end
end
