# == Schema Information
#
# Table name: quickbooks_payment_types
#
#  id                              :integer          not null, primary key
#  name                            :string(255)
#  company_id                      :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  external_id                     :string(255)
#  external_integration_type       :string(255)
#  external_updated_at             :datetime
#  active                          :boolean
#  external_additional_information :text(65535)
#

class QuickbooksPaymentType < ActiveRecord::Base

  has_many :expenses
  belongs_to :company

  scope :quickbooks, -> { where(external_integration_type: FinlyIntegratable::ALLOWED_INTEGRATION_TYPES[0]) }
  scope :checking_account_with_company, -> (id) {
    where(company_id: id).where(name: "Checking")
  }


  validates :external_id, uniqueness: { scope: :external_integration_type, message: "should be unique for an external integration type" }, if: -> { self.external_integration_type.present? }

  def from_quickbooks?
    external_integration_type == FinlyIntegratable::ALLOWED_INTEGRATION_TYPES[0]
  end
end
