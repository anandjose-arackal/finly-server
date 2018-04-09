class Personalizer::Adapters::Company69::Expense69::TimeUpdate69::PreProcess < Personalizer::Adapters::Base

  def pre_process
    expense_params = self.op_instance.updated_expense_params
    expense_params[:reimbursable] = false
    self.op_instance.updated_expense_params = expense_params
  end

end