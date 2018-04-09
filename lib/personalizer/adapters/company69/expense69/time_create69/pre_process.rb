class Personalizer::Adapters::Company69::Expense69::TimeCreate69::PreProcess < Personalizer::Adapters::Base

  def pre_process
    expense_params[:reimbursable] = false
  end

end