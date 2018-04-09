class Personalizer::Adapters::Company69::Expense69::ManualUpdate69::PreProcess < Personalizer::Adapters::Base

  def pre_process
    expense_params[:reimbursable] = false
  end

end