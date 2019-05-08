# == Schema Information
#
# Table name: beneficiary_payment_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BeneficiaryPaymentStatus < ApplicationRecord
  include Seedable

  def self.values
    [:unpaid, :partially_paid, :paid, :open, :retracted, :processing, :approved, :rejected, :auto_approved, :closed, :pending]
  end

  def unpaid?
    self.id == BeneficiaryPaymentStatus.id_for(:unpaid)
  end

  def partially_paid?
    self.id == BeneficiaryPaymentStatus.id_for(:partially_paid)
  end

  def paid?
    self.id == BeneficiaryPaymentStatus.id_for(:paid)
  end

  def open?
    self.id == BeneficiaryPaymentStatus.id_for(:open)
  end

  def processing?
    self.id == BeneficiaryPaymentStatus.id_for(:processing)
  end

  def approved?
    self.id == BeneficiaryPaymentStatus.id_for(:approved)
  end

  def rejected?
    self.id == BeneficiaryPaymentStatus.id_for(:rejected)
  end

  def auto_approved?
    self.id == BeneficiaryPaymentStatus.id_for(:auto_approved)
  end

  def closed?
    self.id == BeneficiaryPaymentStatus.id_for(:closed)
  end

  def retracted?
    self.id == BeneficiaryPaymentStatus.id_for(:retracted)
  end

  def pending?
    self.id == BeneficiaryPaymentStatus.id_for(:pending)
  end

end
