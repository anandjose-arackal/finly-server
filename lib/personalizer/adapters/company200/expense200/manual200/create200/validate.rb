class Personalizer::Adapters::Company200::Expense200::Manual200::Create200::Validate < Personalizer::Adapters::Base

  attr_accessor :expense_params, :category, :validate_keys

  def init
    self.expense_params = op_instance.expense_params
    self.category = current_company.categories.find_by_id expense_params[:category_id]
    self.validate_keys = %w(
                       merchant_bill_no
                       gstin_location_attributes.gstin
                     )
  end

  def process
    return if self.category.blank?
    if category.gst_applicable?
      validate_keys.each do |field_key|
        field_keys = field_key.split('.')
        user_value = field_keys[0...-1].inject(expense_params) do |hash, expence_param|
          hash&.public_send(:[], expence_param.to_sym)
        end&.public_send(:[], field_keys.last)
        if user_value.blank?
          field_name = field_keys.last&.gsub("id", "")&.humanize rescue "Expense Field"
          add_message :error, "#{field_name} can't be blank"
        end
      end

      unless validate_gstin(expense_params.dig(:gstin_location_attributes, :gstin))
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