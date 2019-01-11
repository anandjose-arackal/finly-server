class Personalizer::Adapters::Company69::Expense69::DistanceMultipleCreate::PreProcess < Personalizer::Adapters::Company69::Expense69::Base

  def pre_process
    multiple_expenses = self.op_instance.multiple_expenses
    for key, value in multiple_expenses
      expense = value[:expense]
      expense.reimbursable = false
    end
    self.op_instance.multiple_expenses = multiple_expenses
  end
end