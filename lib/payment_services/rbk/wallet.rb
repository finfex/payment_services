# frozen_string_literal: true

# Copyright (c) 2019 FINFEX https://github.com/finfex

require_relative 'wallet_client'

class PaymentServices::RBK
  class Wallet < ApplicationRecord
    self.table_name = 'rbk_wallets'

    def self.create_for_identity(_identity)
      # {
      #   "name": "Kassa.cc wallet",
      #   "identity": identity.id,
      #   "currency": "RUB"
      # }
      raise NotImplementedError
    end
  end
end
