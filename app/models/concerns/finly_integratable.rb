module QuickbooksFinlyIntegratable
  extend ActiveSupport::Concern
  ALLOWED_INTEGRATION_TYPES = FinlyIntegrationsConstants::ADAPTERS_LIST

  attr_accessor :quickbooks_id, :quickbooks_integration_type, :quickbooks_updated_at, :active, :quickbooks_additional_information, :company_id

  included do
    include ActiveModel::Validations

    validates :quickbooks_integration_type, inclusion: { in: FinlyIntegratable::ALLOWED_INTEGRATION_TYPES }

    validates :quickbooks_id, presence: true
    
    validates :company_id, presence: true
  end
end