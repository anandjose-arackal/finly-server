class Personalizer::Adapters::Company144::Expense144::Manual144::Create144::Validate < Personalizer::Adapters::Base

  attr_accessor :expense_params, :category_id, :purpose

  def init
    self.expense_params = op_instance.expense_params
    self.category_id = self.expense_params[:category_id]
    self.purpose = self.expense_params[:note]
  end

  def process
    if self.category_id&.to_i == 5406
      if self.purpose.blank?
        add_message :error, "Other expenses need to have an associated purpose"
        return
      end
    end
  end
end