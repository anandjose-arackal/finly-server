class TransactionStep

  def self.call(_ctx, *)
    ActiveRecord::Base.transaction { yield }&.first
  end
end

class RollbackStep
  
  def self.call(*)
    raise ActiveRecord::Rollback
  end
end

class Docs::I2P::Invoices::Ops::Update < Transactions::API

  step Model(Invoice, :find_by)
  step Policy::Pundit(Docs::I2P::Invoices::Policy, :update?)
  step Forms::Model::Find()
  step Forms::Contracts::Build()
  step Contract::Validate()
  # step Wrap(TransactionStep){
    step Contract::Persist()
    # step :budget_limit_validation
    # fail RollbackStep
  # }
  step Transactions::Messages::SuccessMessage('Invoice Updated')


  def budget_limit_validation(options, params, ** )
    current_user = options[:current_user]
    model = options[:model]
    if current_user.company.enforce_budget_configuration.enforce_invoice_budget?
      op = BudgetManager::BudgetLimitValidator::Invoice.({invoice: model, previous_budget_contributions: model.invoice_budget_contributions_before_update, current_user: current_user})
      unless op.success?
        add_message options, :error, :base, op.messages[:errors]
        return false 
      end
    end
    return true
  end

end
