class Docs::I2P::Invoices::Ops::SaveAndSubmit < Transactions::API
  step :save
  step :submit

  def save(options, params:, current_user:, **)
    op = Docs::I2P::Invoices::Ops::Update.(params: params, current_user: current_user)

    unless op.success?
      add_message options, :error, :base, op.messages[:errors]
      return
    end

    options['model'] = op['model']

    add_message options, :success, :base, "Invoice Saved"

    true
  end

  def submit(options, params:, current_user:, model:, **)
    submit_params = {
        reviewal_document: model,
        document_reviewer_mappings: params[:document_reviewer_mappings],
        policy_id: params[:policy_id]
    }

    op = Docs::I2P::Invoices::Ops::Submit.(params: submit_params, current_user: current_user)

    unless op.success?
      add_message options, :error, :base, "Error in Submission"
      add_message options, :error, :base, op.messages[:errors]
    end

    add_message options, :success, :base, "Invoice Submitted for Approval"

    true
  end

end