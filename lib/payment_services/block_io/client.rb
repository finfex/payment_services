# frozen_string_literal: true

# Copyright (c) 2020 FINFEX https://github.com/finfex

class PaymentServices::BlockIo
  class Client
    include AutoLogger
    Error = Class.new StandardError

    def initialize(api_key:, pin:)
      @api_key = api_key
      @pin = pin
    end

    def make_payout(address:, amount:, nounce:)
      BlockIo.set_options(api_key: api_key, pin: pin)
      begin
        BlockIo.withdraw(to_addresses: address, amounts: amount, nounce: nounce)
      rescue Exception => error # BlockIo uses Exceptions instead StandardError
        raise Error, error.to_s
      end
    end

    private

    attr_reader :api_key, :pin
  end
end
