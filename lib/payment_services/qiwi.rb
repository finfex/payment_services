# frozen_string_literal: true

# Copyright (c) 2018 FINFEX https://github.com/finfex

module PaymentServices
  class QIWI < Base
    autoload :PayoutAdapter, 'payment_services/qiwi/payout_adapter'
    autoload :Importer, 'payment_services/qiwi/importer'
    autoload :Invoicer, 'payment_services/qiwi/invoicer'

    register :payout_adapter, PayoutAdapter
    register :importer, Importer
    register :invoicer, Invoicer
  end
end
