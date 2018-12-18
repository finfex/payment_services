# Copyright (c) 2018 FINFEX <danil@brandymint.ru>

module PaymentServices
  class EVoucherUSD < Base

    def cheque_input_format
       {
         fields: [
           { name: 'number', title: I18n.t('order.cheque_fields.number') },
           { name: 'pin', title: I18n.t('order.cheque_fields.pin') }
         ],
         validator: 'evoucher-usd'
       }
    end
  end
end
