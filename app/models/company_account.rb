# == Schema Information
#
# Table name: company_accounts
#
#  id                :integer          not null, primary key
#  company_id        :integer          not null
#  wallet_balance_id :integer
#  company           :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class CompanyAccount < ActiveRecord::Base
  belongs_to :company
  belongs_to :wallet_balance, class_name: 'Amount'

  after_create do
    if self.wallet_balance.blank?
      amount = Amount.create(value: 0, currency_id: Currency.first.id)
      self.update_attribute(:wallet_balance_id, amount.id)
    end
  end

  def funds_credited_to_wallet(amount)
    if amount.blank? or amount.to_i <= 0
      errors.add(:amount, 'cannot be less than or equal to 0')
      return false
    end
    new_balance = amount.to_i + self.wallet_balance.value
    unless self.wallet_balance.update_attribute(:value, new_balance)
      @errors.merge!(self.balance.instance_variable_get(:@errors))
      return false
    end
    true
  end

  def funds_debited_from_wallet(amount)
    if amount.blank? or amount.to_i <= 0
      errors.add(:amount, 'cannot be less than or equal to 0')
      return false
    end
    if amount.to_i > self.wallet_balance.value
      errors.add(:amount, 'cannot be greater than the remaining balance in the wallet')
      return false
    end
    new_balance = self.wallet_balance.value - amount.to_i
    unless self.wallet_balance.update_attribute(:value, new_balance)
      @errors.merge!(self.balance.instance_variable_get(:@errors))
      return false
    end
    true
  end

end
