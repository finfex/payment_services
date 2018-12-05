module PaymentServices
  class YandexMoneyPaymentCard < Base
    autoload :Invoicer, 'payment_services/yandex_money_payment_card/invoicer'

    register :invoicer, Invoicer
  end
end
