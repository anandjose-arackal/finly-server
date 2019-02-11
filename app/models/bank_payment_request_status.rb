# == Schema Information
#
# Table name: bank_payment_request_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BankPaymentRequestStatus < ApplicationRecord
  include Seedable

  def self.values
    [:open, :processing, :submitted, :retracted, :rejected, :approved, :unapprove, :credited, :pending, :creation_in_progress, :auto_approved]
  end

  def open?
    self.id == BankPaymentRequestStatus.id_for(:open)
  end

  def processing?
    self.id == BankPaymentRequestStatus.id_for(:processing)
  end

  def retracted?
    self.id == BankPaymentRequestStatus.id_for(:retracted)
  end

  def submitted?
    self.id == BankPaymentRequestStatus.id_for(:submitted)
  end

  def rejected?
    self.id == BankPaymentRequestStatus.id_for(:rejected)
  end

  def approved?
    self.id == BankPaymentRequestStatus.id_for(:approved)
  end

  def credited?
    self.id == BankPaymentRequestStatus.id_for(:credited)
  end

end