# frozen_string_literal: true

# Copyright (c) 2020 FINFEX https://github.com/finfex

require_relative 'client'
# Сервис выплаты на BlockIo. Выполняет запрос на BlockIo-Клиент.
#
class PaymentServices::BlockIo
  class PayoutAdapter < ::PaymentServices::Base::PayoutAdapter
    MIN_PAYOUT_AMOUNT = 0.00002 # Block.io restriction

    def make_payout!(amount:, payment_card_details:, transaction_id:, destination_account:)
      raise 'Можно делать выплаты только в биткоинах' unless amount.currency == BTC
      raise 'Кошелек должен быть биткоиновый' unless wallet.currency == BTC
      raise "Минимальная выплата #{MIN_PAYOUT_AMOUNT}, к выплате #{amount}" if amount.to_f < MIN_PAYOUT_AMOUNT

      super
    end

    private

    # rubocop:disable Lint/UnusedMethodArgument
    def make_payout(amount:, payment_card_details:, transaction_id:, destination_account:)
      # rubocop:enable Lint/UnusedMethodArgument
      client = Client.new(api_key: wallet.api_key, pin: wallet.api_secret)
      client.make_payout(address: destination_account, amount: amount.format(decimal_mark: '.', symbol: nil), nonce: transaction_id)
    end
  end
end
