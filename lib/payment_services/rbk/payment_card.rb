require_relative 'client'
require_relative 'customer'

class PaymentServices::RBK
  class PaymentCard < ApplicationRecord
    self.table_name = 'rbk_payment_cards'

    enum card_type: %i(bank_card applepay googlepay)
    enum binding_type: %i(regular verification)

    belongs_to :rbk_customer, class_name: 'PaymentServices::RBK::Customer', foreign_key: :rbk_customer_id

    after_create :update_verification_state

    def self.fetch_cards_for(customer: customer)
      raw_cards = Client.new.customer_bindings(customer)
      raw_cards.each do |raw_card|
        payment_card = customer.payment_cards.find_by(rbk_id: raw_card['id'])
        create_for_customer(customer: customer, card_data: raw_card) unless payment_card
      end
    end

    def self.create_for_customer(customer: customer, card_data: card_data)
      card_details = card_data.dig('paymentResource', 'paymentToolDetails')
      customer.payment_cards.create!(
        rbk_id: card_data['id'],
        bin: card_details['bin'],
        last_digits: card_details['lastDigits'],
        payment_system: card_details['paymentSystem'],
        card_type: card_details['tokenProvider'] || 'bank_card',
        payload: card_data
      )
    end

    private

    def update_verification_state
      if rbk_customer.processing?
        update!(binding_type: :verification)
        rbk_customer.success!
      end
    end
  end
end
