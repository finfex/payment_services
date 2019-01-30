# frozen_string_literal: true

# Copyright (c) 2019 FINFEX https://github.com/finfex

require_relative 'identity_client'

class PaymentServices::RBK
  class Identity < ApplicationRecord
    self.table_name = 'rbk_identities'

    has_many :rbk_wallets, class_name: 'PaymentServices::RBK::Wallet', foreign_key: :rbk_identity_id

    def self.create_sample!
      response = IdentityClient.new.create_sample_identity
      create!(
        rbk_id: response['id'],
        payload: response
      )
    end
  end
end