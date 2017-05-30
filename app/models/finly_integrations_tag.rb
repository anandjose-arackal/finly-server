class FinlyIntegrationsTag
  include FinlyIntegratable
  QUICKBOOKS_TAG_SUB_TYPES = ['Class', 'Customer', 'Location']

  attr_accessor :name, :tag_sub_type

  validates :name, presence: true

  validates :tag_sub_type, inclusion: { in: QUICKBOOKS_TAG_SUB_TYPES }, if: proc {|finly_category| finly_category.external_integration_type == FinlyIntegratable::ALLOWED_INTEGRATION_TYPES[0] }

  def save
    if self.valid?
      begin
        finly_tag = CompanyTag.find_or_initialize_by(external_integration_type: self.external_integration_type,
          external_id: self.external_id)
        finly_tag.tap do |tag|
          tag.name = self.name
          tag.company_id = self.company_id
          tag.external_updated_at = self.external_updated_at
          tag.active = self.active
          tag.external_additional_information = self.external_additional_information
          tag.external_tag_type = self.tag_sub_type
        end
        finly_tag.save
      rescue ActiveRecord::RecordNotUnique
        retry
      end
    else
      return false
    end
  end
end