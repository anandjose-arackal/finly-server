# == Schema Information
#
# Table name: quickbooks_payment_types
#
#  id                                :integer          not null, primary key
#  name                              :string(255)
#  company_id                        :integer
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  quickbooks_id                     :string(255)
#  quickbooks_integration_type       :string(255)
#  quickbooks_updated_at             :datetime
#  active                            :boolean
#  quickbooks_additional_information :text(65535)
#

class QuickbooksPaymentType < ActiveRecord::Base

  belongs_to :company

  scope :quickbooks, -> { where(quickbooks_integration_type: QuickbooksFinlyIntegratable::ALLOWED_INTEGRATION_TYPES[0]) }
  scope :checking_account_with_company, -> (id) {
    where(company_id: id).where(name: "Checking")
  }

  # validates :quickbooks_id, uniqueness: { scope: :quickbooks_integration_type, message: "should be unique for a quickbooks integration type" }, if: -> { self.quickbooks_integration_type.present? }

  def from_quickbooks?
    quickbooks_integration_type == QuickbooksFinlyIntegratable::ALLOWED_INTEGRATION_TYPES[0]
  end
end
