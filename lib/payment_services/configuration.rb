# frozen_string_literal: true

# Copyright (c) 2018 FINFEX https://github.com/finfex

module PaymentServices
  class Configuration
    attr_accessor :qiwi_timeout

    def initialize
      @qiwi_client_timeout = 1
    end
  end
end
