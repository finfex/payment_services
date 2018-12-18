# Copyright (c) 2018 FINFEX <danil@brandymint.ru>

module PaymentServices
  class WexRUB < Base

    def cheque_input_format
       {
         fields: [
           { name: 'number', title: I18n.t('order.cheque_fields.number') },
         ],
         validator: 'wex-rub'
       }
    end
  end
end
