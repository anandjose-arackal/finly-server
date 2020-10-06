# == Schema Information
#
# Table name: bank_payment_request_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class BankPaymentRequestStatus < NonTenantedApplicationRecord
  include Seedable

  GROUP_OPEN = 90
  GROUP_AWAITING_APPROVAL = 91
  GROUP_PROCESSING = 92
  GROUP_PENDING_CREDIT = 93
  GROUP_FAILED = 94
  GROUP_SCHEDULED = 95
  GROUP_PENDING = 96
  GROUP_PARTIALLY_COMPLETED = 97
  GROUP_COMPLETED = 98

  def self.values
    [:open, :processing, :submitted, :retracted, :rejected,
     :approved, :unapprove, :credited, :pending,
     :creation_in_progress, :auto_approved]
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
    self.id == BankPaymentRequestStatus.id_for(:approved) || self.id == BankPaymentRequestStatus.id_for(:auto_approved)
  end

  def pending?
    self.id == BankPaymentRequestStatus.id_for(:pending)
  end

  def creation_in_progress?
    self.id == BankPaymentRequestStatus.id_for(:creation_in_progress)
  end

  def auto_approved?
    self.id == BankPaymentRequestStatus.id_for(:auto_approved)
  end

  def credited?
    self.id == BankPaymentRequestStatus.id_for(:credited)
  end

  def self.status_ids_for_owner
    [
      BankPaymentRequestStatus.id_for(:open),
      BankPaymentRequestStatus.id_for(:rejected),
      BankPaymentRequestStatus.id_for(:retracted)
    ]
  end

  def self.status_ids_for_reviewer
    [
      BankPaymentRequestStatus.id_for(:processing)
    ]
  end

  def self.status_ids_for_creditor
    [
      BankPaymentRequestStatus.id_for(:approved)
    ]
  end
end
