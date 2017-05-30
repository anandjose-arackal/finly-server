module FinlyIntegratable
  extend ActiveSupport::Concern
  ALLOWED_INTEGRATION_TYPES = FinlyIntegrationsConstants::ADAPTERS_LIST

  attr_accessor :external_id, :external_integration_type, :external_updated_at, :active, :external_additional_information, :company_id

  included do
    include ActiveModel::Validations

    validates :external_integration_type, inclusion: { in: FinlyIntegratable::ALLOWED_INTEGRATION_TYPES }

    validates :external_id, presence: true
    
    validates :company_id, presence: true
  end
end