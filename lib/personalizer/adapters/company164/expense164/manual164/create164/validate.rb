class Personalizer::Adapters::Company164::Expense164::Manual164::Create164::Validate < Personalizer::Adapters::Base

  attr_accessor :expense_params, :purpose

  def init
    self.expense_params = op_instance.expense_params
    self.purpose = expense_params[:note]
  end

  def process
    if self.purpose.blank?
      add_message :error, "Expenses need to have an associated Purpose"
      return
    end
  end
end