# Copyright (c) 2018 FINFEX <danil@brandymint.ru>

module PaymentServices
  class ExmoUSD < Base

    def cheque_input_format
       {
         fields: [
           { name: 'number', title: I18n.t('order.cheque_fields.number') },
         ],
         validator: 'exmo-usd'
       }
    end
  end
end
