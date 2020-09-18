module Monetizable
  extend ActiveSupport::Concern

  module ClassMethods
    def money(amount, currency, as: nil)
      method_name = "#{amount}_money"
      if as.present?
        method_name = as
      end
      define_method method_name do
        if currency.is_a?(Symbol)
          currency_obj = self.send(currency)
        else
          currency_obj = currency.call(self)
        end
        Money.from_amount(self.send(amount), currency_obj.country_code, self.exchange_rate_bank)
      end
    end

    def exchange_bank(reporting_currency, base_currency, exchange_rate)
      define_method 'exchange_rate_bank' do
        bank = Money::Bank::VariableExchange.new(Money::RatesStore::Memory.new)
        # byebug
        bank.add_rate(self.send(reporting_currency).country_code, self.send(base_currency).country_code, self.send(exchange_rate))
        bank.add_rate(self.send(base_currency).country_code, self.send(reporting_currency).country_code, 1.0 / self.send(exchange_rate))
        bank
      end
    end
  end
end