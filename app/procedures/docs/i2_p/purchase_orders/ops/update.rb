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
  step Policy::Pundit(Docs::P2P::PurchaseOrders::Policy, :update?)
  step Forms::Model::Find()
  step :model_status_validation
  step :validate_quotations
  step Wrap(TransactionStep){
    step Forms::Contracts::Build()
    step Contract::Validate()
    step :save_quotations
    step Contract::Persist()
    # step :budget_limit_validation
    fail RollbackStep
  }
  step Transactions::Messages::SuccessMessage('Purchase Order Updated')

  def model_status_validation(options, params, **)
    if options[:model].processing?
      add_message options, :error, :base, "Document already under processing"
      return false
    end

    return true
  end

  def validate_quotations(options, params, ** )
    quotations_params = params[:params][:quotations].reject {|param| param[:_destroy] && param[:id] == "" } rescue nil

    return true if quotations_params.nil?

    errors = false
    
    if quotations_params.pluck(:vendor_name).any? {|vendor_name| vendor_name.to_s.length < 3}
      add_message options, :error, :base, "Quotations > vendor name should be at least 3 characters long"
      errors = true
    end

    if quotations_params.pluck(:vendor_location).any? {|vendor_location| vendor_location.to_s.length < 3}
      add_message options, :error, :base, "Quotations > vendor location should be at least 3 characters long"
      errors = true
    end
    
    if quotations_params.pluck(:note).any? {|note| note.to_s.length < 5}
      add_message options, :error, :base, "Quotations > note should be at least 5 characters long"
      errors = true
    end

    # This validation should be added in the form but tried all combination of fields, it just isn't working
    if params[:params][:po_balance_due].to_f < params[:params][:po_requested_advance_amount].to_f && params[:params][:advance_amount_required]
      add_message options, :error, :base, "Advance amount can not be more than balance payable"
      errors = true
    end

    return !errors
  end

  # Contract::persist only saving the last quote, so creating them manually and deleting the last one
  def save_quotations(options, params, **)
    quotation = nil
    begin
      params[:params][:quotations].each do |q|
        if q[:id] == ""
          quotation_params = q
          quotation = Quotation.new
          quotation.attributes = quotation_params.reject { |k,v| !quotation.attributes.keys.member?(k.to_s) }
          quotation.purchase_order_id = params[:params][:id]
          if quotation.save
            q[:id] = quotation.id
          end
        end
      end
    ensure
        quotation.delete if quotation.present?
    end
  end

  def budget_limit_validation(options, params, ** )
    current_user = options[:current_user]
    model = options[:model]
    if current_user.company.enforce_budget_configuration.enforce_invoice_budget?
      op = BudgetManager::BudgetLimitValidator::PurchaseOrder.({purchase_order: purchase_order, previous_budget_contributions: model.po_budget_contributions_before_update, current_user: user})
      unless op.success?
        add_message options, :error, :base, op.messages[:errors]
        return false 
      end
    end
    return true
  end

end
