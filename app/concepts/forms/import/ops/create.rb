class Forms::Import::Ops::Create < Transactions::API
  step :set_form
  step :find_or_new_model
  step AssignModelUser(key: :created_by)
  step Forms::Contracts::Build()
  step Contract::Validate()
  step :create_procurements
  step :validate_attachments
  step Contract::Persist(method: :sync)
  # step :set_approval_workflow!
  step Transactions::Messages::SuccessMessage('Record Saved')

  def set_form(context, params:, current_user:, **)
    context[:form] = params.delete(:form)
    Rails.logger.info "Import::#{context[:form].label}_form"
    true
  end

  # Invoices and Purchase Orders needs procurements
  def create_procurements(context, form:, params:, current_user:, **)
    return true if form.model == YesBankVendor
    unless context[:model].procurement_id.present?
      proc = Procurement.create({name: "#{params['invoice_number']}"})
      context[:model].procurement_id = proc.id
    end
    return true
  end

  def validate_attachments(context, params:, model:, **)
    if model.class == Invoice
      unless params['invoice_attachments'].present?
        return on_error context, :invoice,'attachments cannot be blank'
      end
    end
    return true
  end

  def find_or_new_model(context, form:, params:, current_user:, **)
    context[:model] = if params[:record_query].present?
                        model = form.model.find_by(params[:record_query])
                        model.nil? ? form.model.new : model
                      else
                        form.model.new
                      end
    Rails.logger.info "Import::#{context[:model]}"
    true
  end

  # Skipping this step for now
  def set_approval_workflow!(context, model:, form:, params:, current_user:, **)
    if model.is_a?(YesBankVendor) && model.status&.awaiting_approval? && !model.dlrms.present?
      document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(current_user, {reviewal_document: model})
      unless document_reviewer_mappings_op.success?
        return on_error context, :workflow, document_reviewer_mappings_op.messages[:error]
      end

      next_level = model.dlrms.with_level_number(1).first&.level
      if next_level.present?
        model.dlrms.with_level_id(next_level&.id).update_all(viewable: true)
        model.update(controlling_level_id: next_level&.id)
      end
    end

    true
  end
end
