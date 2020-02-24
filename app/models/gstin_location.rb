# == Schema Information
#
# Table name: gstin_locations
#
#  id                :bigint           not null, primary key
#  vendor_id         :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  gstin_id          :integer
#  gstin             :string(255)
#  state_id          :integer
#  poc_name          :string(255)
#  poc_mobile_number :string(255)
#  poc_email         :string(255)
#  poc_fax           :string(255)
#  poc_designation   :string(255)
#  location          :string(255)
#  address           :text(65535)
#  deleted_at        :datetime
#

class GstinLocation < ApplicationRecord
  include LiquidDroppable

  belongs_to :vendor, class_name: "YesBankVendor", optional: true
  belongs_to :gstin_master, class_name: "Gstin", foreign_key: :gstin_id, optional: true
  belongs_to :state, class_name: "GstStateCode", optional: true

  # validates :location, presence: true
  validates :state_id, presence: true, if: :check_vendor_gstin_registered?
  validates :gstin, format: Constants::VALID_GSTIN, length: {is: 15}, allow_blank: true

  def state_code
    self.state&.state_code
  end

  # belongs_to :location, class_name: "BranchLocation", optional: true

  def as_json
    {
      id: self.id,
      location: self.location,
      gstin: self.gstin,
      address: self.address
    }
  end

  def check_vendor_gstin_registered?
    return false if self.vendor_id.nil?
    self.vendor.gst_registered
  end
end
