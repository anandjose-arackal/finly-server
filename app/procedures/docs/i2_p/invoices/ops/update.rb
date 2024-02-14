class TransactionStep

  def self.call((ctx), *, &block)
    ActiveRecord::Base.transaction { yield }&.first
  end
end

class RollbackStep
  
  def self.call((ctx), *, &block)
    raise ActiveRecord::Rollback
  end
end

class Docs::I2P::Invoices::Ops::Update < Transactions::API

  step Model(Invoice, :find_by)
  step Policy::Pundit(Docs::I2P::Invoices::Policy, :update?)
  step Forms::Model::Find()
  step Wrap(TransactionStep){
    step Forms::Contracts::Build()
    step Contract::Validate()
    step :validate_credit_note
    step Contract::Persist()
    step :budget_limit_validation
    step :update_credit_notes_data
    fail RollbackStep
  }
  step Transactions::Messages::SuccessMessage('Invoice Updated')

  def model_status_validation(options, params, **)
    if options[:model].processing?
      add_message options, :error, :base, "Document already under processing"
      return false
    end

    return true
  end

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

  def update_credit_notes_data(options, params, **)
    model = options[:model]
    model.credit_note_adjustments.each do |cna|
      cna.update_cn
    end
    return true
  end

  def validate_credit_note(options, params, **)
    current_user = options[:current_user]

    credit_note_adjustments =  options[:params][:credit_note_adjustments]&.select{ |item| item unless item[:_destroy]} || []
    credit_note_ids =  credit_note_adjustments.map{ |item| item[:credit_note_id] if item[:credit_note_id].present? }.compact

    unless credit_note_ids.uniq.length == credit_note_ids.length 
      add_message options, :error, :base, "Applied Credit Note has duplicate"
      return false
    end
    true
  end

  def save_custom_fields(options, params, **)
    model = options[:model]
    model.form_custom_fields.each do |custom_field|
      custom_field.save
    end
  end

end
