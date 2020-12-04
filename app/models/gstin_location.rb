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
#  gst_status        :string(255)
#  gst_expiry_date   :date
#

class GstinLocation < ApplicationRecord
  include LiquidDroppable
  include Exposures::Model::Exposable

  belongs_to :vendor, class_name: "YesBankVendor", optional: true
  belongs_to :gstin_master, class_name: "Gstin", foreign_key: :gstin_id, optional: true
  belongs_to :state, class_name: "GstStateCode", optional: true

  has_many :form_custom_fields, class_name: 'FormCustomField', as: :document
  has_paper_trail(
      meta: {
          parent_document_type: "YesBankVendor"
      }
  )

  # validates :location, presence: true
  # validates :state_id, presence: true, if: :check_vendor_gstin_registered? # todo - I2P : move logic to operations
  validates :gstin, format: Constants::VALID_GSTIN, length: {is: 15}, allow_blank: true

  serialize :gstin_fetch_details, JSON

  def state_code
    self.state&.state_code
  end

  # belongs_to :location, class_name: "BranchLocation", optional: true

  def as_json(options = {})
    {
        id: self.id,
        location: self.location,
        gstin: self.gstin,
        address: self.address,
        state: self.state,
        poc: {
            name: poc_name,
            email: poc_email,
            mobile_number: poc_mobile_number
        }
    }
  end

  def check_vendor_gstin_registered?
    return false if self.vendor_id.nil?
    self.vendor.gst_registered
  end

  def forms_extra_data
    data = {}
    gstin_master = Gstin.with_gstin(self.gstin).first
    if gstin_master.present?
      data.merge!({gstin_fetch_details: {
          address: gstin_master&.address,
          constitution_of_business: gstin_master&.constitution_of_business,
          date_of_registration: gstin_master&.date_of_registration,
          gstin: gstin_master&.gstin,
          legal_name_of_business: gstin_master&.legal_name_of_business,
          match_percentile: StringUtils.fuzzy_string_match(StringUtils.clear_generic_keywords(vendor.business_name), StringUtils.clear_generic_keywords(gstin_master&.legal_name_of_business)),
          state: gstin_master&.state,
          status: gstin_master&.status,
          trade_name: gstin_master&.trade_name,
          valid_response: 'true'
      }})
    end
    data
  end
end
