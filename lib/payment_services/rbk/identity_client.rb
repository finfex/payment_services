# frozen_string_literal: true

# Copyright (c) 2018 FINFEX https://github.com/finfex

require_relative 'client'

class PaymentServices::RBK
  class IdentityClient < PaymentServices::RBK::Client
    URL = 'https://api.rbk.money/wallet/v0/identities'

    def create_sample_identity
      safely_parse http_request(
        url: URL,
        method: :POST,
        body: {
          name: 'Kassa.cc',
          provider: 'test',
          class: 'person'
        }
      )
    end
  end
end
