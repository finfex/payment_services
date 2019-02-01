# frozen_string_literal: true

# Copyright (c) 2019 FINFEX https://github.com/finfex

require_relative 'payout_client'

class PaymentServices::RBK
  class Payout < ApplicationRecord
    self.table_name = 'rbk_payouts'
    Error = Class.new StandardError

    belongs_to :rbk_payout_destination,
               class_name: 'PaymentServices::RBK::PayoutDestination',
               foreign_key: :rbk_payout_destination_id

    belongs_to :rbk_wallet,
               class_name: 'PaymentServices::RBK::Wallet',
               foreign_key: :rbk_wallet_id

    def self.create_from!(destinaion:, wallet:, amount_cents:)
      response = PayoutClient.new.make_payout(
        payout_destination: destinaion,
        wallet: wallet,
        amount_cents: amount_cents
      )
      raise Error, "RBK payout error: #{response}" unless response['status']

      create!(
        rbk_payout_destination: destinaion,
        rbk_wallet: wallet,
        amount_cents: amount_cents,
        payload: response,
        rbk_status: response['status']
      )
    end
  end
end
