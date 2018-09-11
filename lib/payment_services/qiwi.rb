module PaymentServices
  class QIWI < Base
    autoload :PayoutAdapter, 'payment_services/qiwi/payout_adapter'
    autoload :Importer, 'payment_services/qiwi/importer'

    register :payout_adapter, PayoutAdapter
    register :importer, Importer
  end
end
