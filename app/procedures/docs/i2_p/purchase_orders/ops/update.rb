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

class Docs::I2P::PurchaseOrders::Ops::Update < Transactions::API

  step Model(PurchaseOrder, :find_by)
  step Policy::Pundit(Docs::P2P::PurchaseOrders::Policy, :show?)
  step Forms::Model::Find()
  step Forms::Contracts::Build()
  step Contract::Validate()
  step Transactions::Messages::SuccessMessage('Purchase Order Updated')
  step Wrap(TransactionStep){
    step Contract::Persist()
    # step :budget_limit_validation
    fail RollbackStep
  }

  # def budget_limit_validation(options, params, ** )
  #   current_user = options[:current_user]
  #   model = options[:model]
  #   if current_user.company.enforce_budget_configuration.enforce_invoice_budget?
  #     op = return BudgetManager::BudgetLimitValidator::PurchaseOrder.({purchase_order: purchase_order, previous_budget_contributions: model.po_budget_contributions_before_update, current_user: user})
  #     unless op.success?
  #       add_message options, :error, :base, op.messages[:errors]
  #       return false 
  #     end
  #   end
  #   return true
  # end

end
