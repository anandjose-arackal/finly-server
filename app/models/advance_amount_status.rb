# == Schema Information
#
# Table name: advance_amount_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AdvanceAmountStatus < ApplicationRecord
  include Seedable
  def self.values
    %w( to_be_processed initiated paid failed pending)
  end

  def to_be_processed?
    self.id == AdvanceAmountStatus.id_for(:to_be_processed)
  end

  def initiated?
    self.id == AdvanceAmountStatus.id_for(:initiated)
  end

  def paid?
    self.id == AdvanceAmountStatus.id_for(:paid)
  end

  def failed?
    self.id == AdvanceAmountStatus.id_for(:failed)
  end

  def pending?
    self.id == AdvanceAmountStatus.id_for(:pending)
  end
end
