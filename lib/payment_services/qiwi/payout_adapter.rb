require_relative 'client'
# Сервис выплаты на QIWI. Выполняет запрос на QIWI-Клиент.
#
class PaymentServices::QIWI
  class PayoutAdapter < ::PaymentServices::Base::PayoutAdapter

    # TODO заменить на before_ ?
    #
    def make_payout!(amount:, destination_account:, transaction_id: )
      raise 'Можно делать выплаты только в рублях' unless amount.currency == RUB
      raise 'Кошелек должен быть рублевый' unless wallet.currency == RUB
      super
    end

    private

    def make_payout amount:, transaction_id: , destination_account:
      client.create_payout(
        id:      transaction_id,
        amount:  amount.to_f,
        destination_account: destination_account
      )
    end

    def client
      @client ||= Client.new phone: wallet.qiwi_phone, token: wallet.api_key
    end
  end
end
