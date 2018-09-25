module PaymentServices
  class YandexMoney < Base
    autoload :Invoicer, 'payment_services/yandex_money/invoicer'

    register :invoicer, Invoicer
  end
end
