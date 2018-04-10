class Personalizer::Adapters::Company69::Expense69::PerDiemCreate69::PreProcess < Personalizer::Adapters::Company69::Expense69::Base

  def pre_process
    expense_params = self.op_instance.expense_params
    expense_params[:reimbursable] = false
    self.op_instance.expense_params = expense_params
  end

end