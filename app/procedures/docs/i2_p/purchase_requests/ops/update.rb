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

class Docs::I2P::PurchaseRequests::Ops::Update < Transactions::API

  step Model(PurchaseRequest, :find_by)
  step Policy::Pundit(Docs::I2P::PurchaseRequests::Policy, :update?)
  step Forms::Model::Find()
  step :model_status_validation
  step Wrap(TransactionStep){
    step Forms::Contracts::Build()
    step Contract::Validate()
    step Contract::Persist()
    step :budget_limit_validation
    fail RollbackStep
  }
  step Transactions::Messages::SuccessMessage('Purchase Request Updated')

  def model_status_validation(options, params, **)
    if options[:model].purchase_request_status_id == PurchaseRequestStatus.id_for(:awaiting_approval)
      add_message options, :error, :base, "Document already under processing"
      return false
    end

    return true
  end

  def budget_limit_validation(options, params, ** )
    current_user = options[:current_user]
    model = options[:model]
    
    if current_user.company.enforce_budget_configuration.enforce_purchase_request_budget?
      op = BudgetManager::BudgetLimitValidator::PurchaseRequest.({ purchase_request: model, previous_budget_contributions: model.purchase_request_budget_contributions_before_update, current_user: current_user })
      unless op.success?
        add_message options, :error, :base, op.messages[:errors]
        return false 
      end
    end
    return true
  end

end
