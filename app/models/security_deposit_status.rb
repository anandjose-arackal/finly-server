# == Schema Information
#
# Table name: security_deposit_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class SecurityDepositStatus < ApplicationRecord
  include Seedable

  def self.values
    [:unpaid, :partially_paid, :paid, :open, :retracted, :processing, :approved, :rejected, :auto_approved, :closed, :pending]
  end

  def unpaid?
    self.id == SecurityDepositStatus.id_for(:unpaid)
  end

  def partially_paid?
    self.id == SecurityDepositStatus.id_for(:partially_paid)
  end

  def paid?
    self.id == SecurityDepositStatus.id_for(:paid)
  end

  def open?
    self.id == SecurityDepositStatus.id_for(:open)
  end

  def processing?
    self.id == SecurityDepositStatus.id_for(:processing)
  end

  def approved?
    self.id == SecurityDepositStatus.id_for(:approved)
  end

  def rejected?
    self.id == SecurityDepositStatus.id_for(:rejected)
  end

  def auto_approved?
    self.id == SecurityDepositStatus.id_for(:auto_approved)
  end

  def closed?
    self.id == SecurityDepositStatus.id_for(:closed)
  end

  def retracted?
    self.id == SecurityDepositStatus.id_for(:retracted)
  end

  def pending?
    self.id == SecurityDepositStatus.id_for(:pending)
  end
end
