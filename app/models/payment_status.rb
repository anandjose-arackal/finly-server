# == Schema Information
#
# Table name: payment_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class PaymentStatus < ApplicationRecord
  # Documentation at end of the file
  VALUES = {
      completed: 1,
      failed: 2,
      pending: 3,
      in_progress: 4,
      scheduled: 5,
      cancelled: 6,
      processing: 7,
      pending_approval: 8,
      possible_failure: 9,
      pending_credit: 10,
      pending_retry: 11,
      initiated: 12
  }

  scope :with_name, ->(name) { where name: name }

  def self.id_for(key)
    VALUES[key]
  end

  def self.seed_data
    count == PaymentStatus.count
    VALUES.each do |key, value|
      if PaymentStatus.with_name(key).blank?
        PaymentStatus.create id: value, name: key
      end
    end
  end

  def completed?
    self.id == PaymentStatus.id_for(:completed)
  end

  def failed?
    self.id == PaymentStatus.id_for(:failed)
  end

  def pending?
    self.id == PaymentStatus.id_for(:pending)
  end

  def in_progress?
    self.id == PaymentStatus.id_for(:in_progress)
  end

  def scheduled?
    self.id == PaymentStatus.id_for(:scheduled)
  end

  def processing?
    self.id == PaymentStatus.id_for(:processing)
  end

  def possible_failure?
    self.id == PaymentStatus.id_for(:possible_failure)
  end

  def pending_approval?
    self.id == PaymentStatus.id_for(:pending_approval)
  end

  def pending_retry?
    self.id == PaymentStatus.id_for(:pending_retry)
  end

  def initiated?
    self.id == PaymentStatus.id_for(:initiated)
  end

  def self.status_ids_for_invoice_initiated
    [
        PaymentStatus.id_for(:initiated),
        PaymentStatus.id_for(:pending_credit),
        PaymentStatus.id_for(:pending_approval),
        PaymentStatus.id_for(:processing),
        PaymentStatus.id_for(:in_progress),
        PaymentStatus.id_for(:pending)
    ]
  end

  def self.all_except_failed
    [
        PaymentStatus.id_for(:initiated),
        PaymentStatus.id_for(:pending_credit),
        PaymentStatus.id_for(:pending_approval),
        PaymentStatus.id_for(:processing),
        PaymentStatus.id_for(:in_progress),
        PaymentStatus.id_for(:pending),
        PaymentStatus.id_for(:completed),
        PaymentStatus.id_for(:scheduled),
        PaymentStatus.id_for(:possible_failure),
        PaymentStatus.id_for(:processing)
    ]
  end

end


# #####################
# Order of Payment Statuses
# #####################
#
# Pending Approval(8) -> [Pending(3)/Scheduled(5)] -> In Progress(4) -> [Initiated(12)/Completed(1)/Failed(2)/Processing(7)]
#
# Scheduled -> In Progress(4) -> [Initiated(12)/Completed(1)/Failed(2)/Processing(7)]
#
# Processing(7) -> [Completed(1)/Failed(2)]
#
#
#
# #####################
# Meaning of Statuses
# #####################
# Pending(3)/In Progress(4) : Intermediate Status; Used during creation/processing of payments
# Completed(1) : Payment successfully processed
# Failed(2) : Payment Failed
# Processing(7) : Payment processing at Bank's end after successful initiation
#
