class Personalizer::Adapters::Company189::Expense189::Manual189::Create189::Validate < Personalizer::Adapters::Base

  attr_accessor :expense_params, :category

  def init
    self.expense_params = op_instance.expense_params
    self.category = current_company.categories.find_by_id expense_params[:category_id]
  end

  def process
    return if self.category.blank?
    if ["545302","545102"].include?(self.category.gl_code)

      unless expense_params.dig(:usage_date_start).present?
        add_message :error, "Add Check-In Date"
      end

      unless expense_params.dig(:usage_date_end).present?
        add_message :error, "Add Check-Out Date"
      end
    end
  end
end