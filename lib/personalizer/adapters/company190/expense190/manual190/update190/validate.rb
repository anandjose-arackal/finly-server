class Personalizer::Adapters::Company190::Expense190::Manual190::Update190::Validate < Personalizer::Adapters::Base

  attr_accessor :expense_params, :category,:validate_keys

  def init
    self.expense_params = op_instance.params
    self.category = current_company.categories.find_by_id expense_params[:category_id]
    self.validate_keys = %w(
                       expense_tax_type_id
                       tax_rate_id
                       gst_type_id
                       state_of_expense_id
                       hsn_sac
                       merchant_bill_no
                       gstin_location_attributes.gstin
                       gstin_location_attributes.state_id
                     )
  end

  def process
    return if self.category.blank?
    if category.gst_applicable?
      validate_keys.each do |field_key|
        field_keys = field_key.split('.')
        user_value = field_keys[0...-1].inject(expense_params) do |hash, expense_param|
          hash&.public_send(:[], expense_param.to_sym)
        end&.public_send(:[], field_keys.last)
        if user_value.blank?
          field_name = field_keys.last&.gsub("id","")&.humanize rescue "Expense Field"
          add_message :error, "#{field_name} can't be blank"
        end
      end

      unless validate_gstin(expense_params.dig(:gstin_location_attributes,:gstin))
        add_message :error, "GSTIN Invalid"
      end
    end
  end

  def validate_gstin(item)
    pattern = Regexp.new(Constants::VALID_GSTIN)
    if item =~ pattern
      return true
    else
      return false
    end
  end
end