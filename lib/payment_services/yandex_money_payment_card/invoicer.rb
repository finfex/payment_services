require_relative 'invoice'

class PaymentServices::YandexMoneyPaymentCard
  class Invoicer < ::PaymentServices::Base::Invoicer
    def create_invoice(money)
    end

    def invoice_form_data
      description = I18n.t('payment_systems.personal_payment', order_id: order.public_id)
      {
        url: 'https://money.yandex.ru/quickpay/confirm.xml',
        method: 'POST',
        target: '_blank',
        inputs: {
          receiver: order.income_wallet.account,
          formcomment: description,
          shortvalue: description,
          targets: description,
          label: order.public_id,
          sum: order.income_money_with_fee.to_f,
          paymentType: 'AC',
          'quickpay-form' => 'shop'
        }
      }
    end
  end
end
