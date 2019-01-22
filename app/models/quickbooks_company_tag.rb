class QuickbooksCompanyTag < ApplicationRecord

  belongs_to :company_tag, optional: true

  scope :quickbooks, -> { where(quickbooks_integration_type: QuickbooksFinlyIntegratable::ALLOWED_INTEGRATION_TYPES[0]) }

  validates :quickbooks_id, uniqueness: { scope: :quickbooks_integration_type, message: "should be unique for a quickbooks integration type" }, if: lambda { |company_tag| company_tag.quickbooks_integration_type.present? }

  def from_quickbooks?
    quickbooks_integration_type == QuickbooksFinlyIntegratable::ALLOWED_INTEGRATION_TYPES[0]
  end
end