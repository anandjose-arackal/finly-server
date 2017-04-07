# == Schema Information
#
# Table name: user_wallets
#
#  id         :integer          not null, primary key
#  balance_id :integer          not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserWallet < ActiveRecord::Base
  belongs_to :user
  belongs_to :balance, class_name: 'Amount'

  has_many :initiating_payments, as: :initiating_account
  has_many :receiving_payments, as: :receiving_account

  validates :user, presence: true

  accepts_nested_attributes_for :balance

  def balance_value
    self.balance.value
  end

  alias_method :balance_amount, :balance_value

  def add_funds(amount)
    if amount.blank? or amount.to_d <= 0
      errors.add(:amount, 'cannot be less than or equal to 0')
      return false
    end
    new_balance = amount.to_d + self.balance_value
    unless self.balance.update_attribute(:value, new_balance)
      @errors.merge!(self.balance.instance_variable_get(:@errors))
      return false
    end
    true
  end

  def subtract_funds(amount)
    if amount.blank? or amount.to_d <= 0
      errors.add(:amount, 'cannot be less than or equal to 0')
      return false
    end
    if amount.to_d > self.balance_value
      errors.add(:amount, 'cannot be greater than the remaining balance in the wallet')
      return false
    end
    new_balance = self.balance_value - amount.to_d
    unless self.balance.update_attribute(:value, new_balance)
      @errors.merge!(self.balance.instance_variable_get(:@errors))
      return false
    end
    true
  end
end
