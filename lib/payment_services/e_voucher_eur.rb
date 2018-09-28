module PaymentServices
  class EVoucherEUR < Base

    def cheque_input_format
       {
         fields: [
           { name: 'number', title: I18n.t('order.cheque_fields.number')},
           { name: 'pin', title: I18n.t('order.cheque_fields.pin') }
         ],
         validator: 'evoucher-eur'
       }
    end
  end
end
