# frozen_string_literal: true

# Copyright (c) 2020 FINFEX https://github.com/finfex

module PaymentServices
  class CryptoApis < Base
    autoload :Invoicer, 'payment_services/crypto_apis/invoicer'
    register :invoicer, Invoicer
  end
end
