# == Schema Information
#
# Table name: vendor_statuses
#
#  id         :bigint(8)        not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class VendorStatus < ApplicationRecord
  include Seedable

  def self.values
    %w( draft awaiting_approval rejected approved auto_approved )
  end

  def draft?
    self.id == VendorStatus.id_for(:draft)
  end

  def awaiting_approval?
    self.id == VendorStatus.id_for(:awaiting_approval)
  end

  def approved?
    self.id == VendorStatus.id_for(:approved)
  end

  def rejected?
    self.id == VendorStatus.id_for(:rejected)
  end
end
