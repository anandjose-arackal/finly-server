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
    %w( draft awaiting_approval retracted rejected approved auto_approved deactivated )
  end

  scope :with_id, -> (ids) {
    where id: ids
  }

  def retracted?
    self.id == VendorStatus.id_for(:retracted)
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

  def auto_approved?
    self.id == VendorStatus.id_for(:auto_approved)
  end

  def deactivated?
    self.id == VendorStatus.id_for(:deactivated)
  end

  def as_json
    {id: id, name: name, display_name: name.split("_").map(&:capitalize).join(" ")}
  end
end
