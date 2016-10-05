# == Schema Information
#
# Table name: amounts
#
#  id          :integer          not null, primary key
#  value       :float(24)
#  currency_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#


class Amount < ActiveRecord::Base
  include MathUtil
  belongs_to :currency

  # def self.get(currency_id, value, force_create: false)
  #   item = find_by(currency_id: currency_id, value: value)
  #   if item.blank? and force_create
  #     return Amount.create!(currency_id: currency_id, value: value)
  #   end
  #   return item
  # end

  validate :no_negative_amount


  validates :currency_id, presence: true

  before_create do
    if self.value.nil?
      self.value = 0
    end
  end

  # method that returns the amount value
  def amount_value
    self.value
  end

  alias_method :transaction_amount_value, :amount_value
  alias_method :pending_reimbursement_value, :amount_value

  def greater_than_amount_value
    self.value
  end

  def greater_than_amount_currency_id
    self.currency_id
  end

  # method that returns the currency code
  def currency_country_code
    self.currency.country_code
  end

  def precision_value
    super(self.value)
  end

  private

  def no_negative_amount
    if self.value and self.value < 0
      errors.add(:amount, 'cannot be negative')
    end
  end

end
