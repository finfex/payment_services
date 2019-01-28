# frozen_string_literal: true

# Copyright (c) 2019 FINFEX https://github.com/finfex

require_relative 'identity_client'

class PaymentServices::RBK
  class Customer < ApplicationRecord
    self.table_name = 'rbk_identities'

    def self.create_sample
      # создание тестовой личность у РБК
      # IdentityClient.new.create_sample_identity
      raise NotImplementedError
    end
  end
end
