class Amount < ActiveRecord::Base
  belongs_to :currency

  # def self.get(currency_id, value, force_create: false)
  #   item = find_by(currency_id: currency_id, value: value)
  #   if item.blank? and force_create
  #     return Amount.create!(currency_id: currency_id, value: value)
  #   end
  #   return item
  # end

  # delegated from expense model
  def amount_value
    self.value
  end

  def currency_id
    self.currency.country_code
  end

end
