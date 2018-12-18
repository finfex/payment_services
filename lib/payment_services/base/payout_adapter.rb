# Copyright (c) 2018 FINFEX <danil@brandymint.ru>

# Адаптер выполняющий запрос на специфичный API-клиент для непосредственной выплаты
#

class PaymentServices::Base
  class PayoutAdapter
    include Virtus.model strict: true

    attribute :wallet #, Wallet

    # amount - сумма выплаты (Money)
    # transaction_id - идентификатор транзакции (платежки) для записи в журнал на внешнем API
    #
    def make_payout!(amount:, transaction_id: , destination_account: )
      raise unless amount.is_a? Money

      make_payout amount: amount, transaction_id: transaction_id, destination_account: destination_account
    end

    private

    def make_payout amount:, transaction_id: , destination_account:
      raise 'not implemented'
    end
  end
end
