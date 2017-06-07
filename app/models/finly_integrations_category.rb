class FinlyIntegrationsCategory
  include FinlyIntegratable
  QUICKBOOKS_CATEGORY_SUB_TYPES = ['Account', 'Item']

  attr_accessor :name, :category_sub_type

  validates :name, presence: true

  validates :category_sub_type, inclusion: { in: QUICKBOOKS_CATEGORY_SUB_TYPES }, if: proc {|finly_category| finly_category.external_integration_type == FinlyIntegratable::ALLOWED_INTEGRATION_TYPES[0] }

  def save
    if self.valid?
      begin
        additional_information_json = JSON.parse self.external_additional_information
        if is_payment? additional_information_json
          finly_category = QuickbooksPaymentType.find_or_initialize_by(external_integration_type: self.external_integration_type,
          external_id: self.external_id)
        elsif is_expense?(additional_information_json) || self.category_sub_type == QUICKBOOKS_CATEGORY_SUB_TYPES.last
          finly_category = Category.find_or_initialize_by(external_integration_type: self.external_integration_type,
          external_id: self.external_id, external_category_type: self.category_sub_type)
        end
        if finly_category.present?
          finly_category.tap do |category|
            category.company_id = self.company_id
            category.name = self.name
            category.external_updated_at = self.external_updated_at
            category.active = self.active
            category.external_additional_information = self.external_additional_information
            category.external_category_type = self.category_sub_type unless is_payment? additional_information_json
          end
          finly_category.save
        end
      rescue ActiveRecord::RecordNotUnique
        #retry
      end
    else
      return false
    end
  end

  def is_payment?(additional_information_json)
    FinlyIntegrationsConstants::CATEGORY_PAYMENT_TYPES.include? additional_information_json['account_type']
  end

  def is_expense?(additional_information_json)
    FinlyIntegrationsConstants::QUICKBOOKS_ACCOUNT_EXPENSE_TYPE == additional_information_json['account_type']
  end
end