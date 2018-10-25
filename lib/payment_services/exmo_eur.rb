module PaymentServices
  class ExmoEUR < Base
    def cheque_input_format
       {
         fields: [
           { name: 'number', title: I18n.t('order.cheque_fields.number') },
         ],
         validator: 'exmo-eur'
       }
    end
  end
end
