class QuickbooksFinlyIntegrationsCategory
  include QuickbooksFinlyIntegratable
  QUICKBOOKS_CATEGORY_SUB_TYPES = ['Account', 'Item']

  attr_accessor :name, :category_sub_type

  validates :name, presence: true

  validates :category_sub_type, inclusion: { in: QUICKBOOKS_CATEGORY_SUB_TYPES }, if: proc {|finly_category| finly_category.quickbooks_integration_type == QuickbooksFinlyIntegratable::ALLOWED_INTEGRATION_TYPES[0] }

  def save
    if self.valid?
      begin
        additional_information_json = JSON.parse self.quickbooks_additional_information
        finly_integrations_category = nil
        if is_inventory_item?(additional_information_json) || is_category?(additional_information_json)
          return
        elsif is_payment? additional_information_json
          finly_integrations_category = QuickbooksPaymentType.find_or_initialize_by(quickbooks_integration_type: self.quickbooks_integration_type,
          quickbooks_id: self.quickbooks_id)
        elsif is_expense?(additional_information_json) || self.category_sub_type == QUICKBOOKS_CATEGORY_SUB_TYPES.last
          finly_integrations_category = QuickbooksCategory.find_or_initialize_by(quickbooks_integration_type: self.quickbooks_integration_type,
          quickbooks_id: self.quickbooks_id, quickbooks_category_type: self.category_sub_type, company_id: self.company_id)
        end
        if finly_integrations_category&.present?
          if finly_integrations_category.is_a?(QuickbooksCategory)
            category_params = {category_attributes: {}}
            category_params[:category_attributes][:company_id] = self.company_id
            category_params[:category_attributes][:name] = self.name
            category_params[:quickbooks_updated_at] = self.quickbooks_updated_at
            category_params[:category_attributes][:active] = self.active
            category_params[:quickbooks_additional_information] = self.quickbooks_additional_information
            category_params[:quickbooks_category_type] = self.category_sub_type unless is_payment? additional_information_json
            finly_integrations_category.update(category_params)
          elsif finly_integrations_category.is_a?(QuickbooksPaymentType)
            finly_integrations_category.name = self.name
            finly_integrations_category.company_id = self.company_id
            finly_integrations_category.quickbooks_additional_information = self.quickbooks_additional_information
            finly_integrations_category.save
          end
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

  def is_inventory_item?(additional_information_json)
    if additional_information_json['type'] == "Inventory"
      return true
    end
  end

  def is_category?(additional_information_json)
    if additional_information_json['type'] == "Category"
      return true
    end
  end
end