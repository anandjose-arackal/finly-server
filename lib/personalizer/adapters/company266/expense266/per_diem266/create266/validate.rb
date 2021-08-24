class Personalizer::Adapters::Company266::Expense266::PerDiem266::Create266::Validate < Personalizer::Adapters::Base

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