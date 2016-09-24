# == Schema Information
#
# Table name: balance_sheets
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  cash_in_hand_id          :integer
#  pending_reimbursement_id :integer
#  pending_advance_id       :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class BalanceSheet < ActiveRecord::Base
  belongs_to :user
  belongs_to :cash_in_hand, class_name: 'Amount'
  belongs_to :pending_reimbursement, class_name: 'Amount'
  belongs_to :pending_advance, class_name: 'Amount'

  delegate :pending_reimbursement_value, to: :pending_reimbursement

  validates :user_id, uniqueness: true, presence: true

  before_save do
    if self.cash_in_hand.blank?
      amount = Amount.create(value: 0, currency: Currency.first)
      self.cash_in_hand = amount
    end
    if self.pending_reimbursement.blank?
      amount = Amount.create(value: 0, currency: Currency.first)
      self.pending_reimbursement= amount
    end
    if self.pending_advance.blank?
      amount = Amount.create(value: 0, currency: Currency.first)
      self.pending_advance = amount
    end
  end

  def add_cash_in_hand(value, currency=nil)
    if value.present? and value.to_f <= 0
      errors.add(:value, 'cannot be less than 0')
      return false
    end
    value = value.to_f
    cih= self.cash_in_hand
    cih.value += value
    if cih.save
      return true
    end
    false
  end

  def subtract_cash_in_hand(value, currency=nil)
    if value.blank? or value.to_f <= 0
      return
    end
    value = value.to_f
    cih = self.cash_in_hand
    cih.value -= value
    cih.value = 0 if cih.value < 0
    cih.save
  end

  def add_pending_reimbursement(value, currency=nil)
    if value.present? and value.to_f <= 0
      return
    end
    value = value.to_f
    pr = self.pending_reimbursement
    pr.value += value
    pr.save
  end

  def subtract_pending_reimbursement(value, currency=nil)
    if value.present? and value.to_f <= 0
      return
    end
    value = value.to_f
    pr = self.pending_reimbursement
    pr.value -= value
    pr.value = 0 if pr.value < 0
    pr.save
  end

  def add_pending_advance(value, currency=nil)
    if value.present? and value.to_f <= 0
      return
    end
    value = value.to_f
    pa = self.pending_advance
    pa.value += value
    pa.save
  end

  def subtract_pending_advance(value, currency=nil)
    if value.present? and value.to_f <= 0
      return
    end
    value = value.to_f
    pr = self.pending_advance
    pr.value -= value
    pr.value = 0 if pr.value < 0
    pr.save
  end

end
