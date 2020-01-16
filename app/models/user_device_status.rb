# == Schema Information
#
# Table name: user_device_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserDeviceStatus < ApplicationRecord
  include Seedable

  def self.values
    [:unverified, :verified, :incomplete, :attribute_mismatch, :complete]
  end

  def unverified?
    self.id == UserDeviceStatus.id_for(:unverified)
  end

  def verified?
    self.id == UserDeviceStatus.id_for(:verified)
  end

  def incomplete?
    self.id == UserDeviceStatus.id_for(:incomplete)
  end

  def attribute_mismatch?
    self.id == UserDeviceStatus.id_for(:attribute_mismatch)
  end

  def complete?
    self.id == UserDeviceStatus.id_for(:complete)
  end

end
