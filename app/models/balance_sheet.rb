# == Schema Information
#
# Table name: balance_sheets
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  cash_in_hand_id          :integer
#  pending_reimbursement_id :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class BalanceSheet < ActiveRecord::Base
  belongs_to :user
  belongs_to :cash_in_hand, class_name: 'Amount'
  belongs_to :pending_reimbursement, class_name: 'Amount'

  before_create do
    if self.cash_in_hand.blank?
      amount = Amount.create(value: 0, currency: Currency.first)
      self.cash_in_hand = amount
    end
    if self.pending_reimbursement.blank?
      amount = Amount.create(value: 0, currency: Currency.first)
      self.pending_reimbursement= amount
    end
  end

  def add_cash_in_hand(value, currency=nil)
    if value <= 0
      errors.add(:value, 'cannot be less than 0')
      return false
    end
    self.cash_in_hand.value += value
    self.cash_in_hand.save
    true
  end

  def subtract_cash_in_hand(value, currency=nil)
    if value <= 0
      return
    end
    self.cash_in_hand.value -= value
    self.cash_in_hand.value = 0 if self.cash_in_hand.value < 0
    self.cash_in_hand.save
  end

  def add_pending_reimbursement(value, currency=nil)
    if value <= 0
      return
    end
    self.pending_reimbursement.value += value
    self.pending_reimbursement.save
  end

  def subtract_pending_reimbursement(value, currency=nil)
    if value <= 0
      return
    end
    self.pending_reimbursement.value -= value
    self.pending_reimbursement.value = 0 if self.pending_reimbursement.value < 0
    self.pending_reimbursement.save
  end

end
