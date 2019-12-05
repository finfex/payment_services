# frozen_string_literal: true

# Copyright (c) 2018 FINFEX https://github.com/finfex

module PaymentServices
  class AliKassa < Base
    autoload :Invoicer, 'payment_services/ali_kassa/invoicer'
    register :invoicer, Invoicer
  end
end
