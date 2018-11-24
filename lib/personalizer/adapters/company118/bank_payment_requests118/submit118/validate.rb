class Personalizer::Adapters::Company118::BankPaymentRequests118::Submit118::Validate < Personalizer::Adapters::Base

  attr_accessor :bank_payment_request, :budgets
  def init
    self.bank_payment_request = op_instance.bank_payment_request

    op = BudgetsCalculator::RelevantBudgets.(user, object: self.bank_payment_request)
    if op.success?
      self.budgets = op.budget_data
    end
  end

  def validate
    unless self.bank_payment_request.present?
      add_message :error, "Payment Order not found"
    end
  end

  def process
    self.budgets.each do |budget|
      budget_amount = budget[:budget].budget_amount.value
      budget_spent_amount = budget[:spent_amount]

      spent_amount = budget_spent_amount

      if spent_amount > budget_amount
        add_message :error, "Payment Order Amount exceeding Budget - #{budget[:budget].name}"
      end
    end

    if messages[:error].present?
      add_message :error, 'Please contact finance to allocate more budget'
    end
  end

end