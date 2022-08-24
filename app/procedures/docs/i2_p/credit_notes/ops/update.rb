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

class Docs::I2P::CreditNotes::Ops::Update < Transactions::API

  step Model(CreditNote, :find_by)
  # step Policy::Pundit(Docs::P2P::CreditNotes::Policy, :update?)
  step Forms::Model::Find()
  step Forms::Contracts::Build()
  step Contract::Validate()
  step Wrap(TransactionStep){
    step Contract::Persist()
    fail RollbackStep
  }
  step Transactions::Messages::SuccessMessage('Credit Note Updated')

end
