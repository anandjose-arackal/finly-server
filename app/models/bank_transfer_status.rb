# == Schema Information
#
# Table name: bank_transfer_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BankTransferStatus < ApplicationRecord

  include Seedable

  def self.values
    [:completed, :processing, :failed, :possible_failure, :open, :pending, :cancelled, :suspect, :pending_for_processing]
  end

  def completed?
    self.id == BankTransferStatus.id_for(:completed)
  end

  def processing?
    self.id == BankTransferStatus.id_for(:processing)
  end

  def retriable?
    self.id == BankTransferStatus.id_for(:failed)
  end

  def failed?
    self.id == BankTransferStatus.id_for(:failed)
  end

  def open?
    self.id == BankTransferStatus.id_for(:open)
  end

  def possible_failure?
    self.id == BankTransferStatus.id_for(:possible_failure)
  end

  def pending_for_processing?
    self.id == BankTransferStatus.id_for(:pending_for_processing)
  end

  def suspect?
    self.id == BankTransferStatus.id_for(:suspect)
  end

end
