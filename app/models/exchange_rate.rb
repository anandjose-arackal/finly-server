# == Schema Information
#
# Table name: exchange_rates
#
#  id         :bigint           not null, primary key
#  from       :string(255)
#  to         :string(255)
#  rate       :float(24)
#  date       :date
#  deleted_at :datetime
#

class ExchangeRate < ApplicationRecord
  def self.populate_rates(date)
    oxr = Money::Bank::OpenExchangeRatesBank.new
    oxr.app_id = OPEN_EXCHANGE_RATES['app_id']
    oxr.date = date.strftime('%Y-%m-%d') rescue nil
    oxr.update_rates
    oxr.oer_rates.each do |to_currency, rate|
      self.add_rate(date, 'USD', to_currency, rate)
    end
  end

  def self.get_rate(date, from_iso_code, to_iso_code)
    if from_iso_code == to_iso_code
      return 1.0
    end

    if date == Date.today
      unless ::LATEST_EXCHANGE_RATES.rates.present?
        ::LATEST_EXCHANGE_RATES.update_rates
      end
      return ::LATEST_EXCHANGE_RATES.get_rate(from_iso_code, to_iso_code)
    end

    if from_iso_code == 'USD'
      rate = find_by(date: date, from: 'USD', to: to_iso_code)
      if rate.present?
        return rate.rate
      end
      self.populate_rates(date)
      rate = find_by(date: date, from: 'USD', to: to_iso_code)
      if rate.present?
        return rate.rate
      else
        return nil
      end
    else
      rate1 = self.get_rate(date, 'USD', from_iso_code)
      rate2 = self.get_rate(date, 'USD', to_iso_code)
      unless rate1.present? and rate2.present?
        return nil
      end
      return rate2 / rate1
    end
  end

  def self.add_rate(date, from_iso_code, to_iso_code, rate)
    exchange_rate = find_or_initialize_by(date: date, from: from_iso_code, to: to_iso_code)
    exchange_rate.rate = rate
    exchange_rate.save!
  end
end
