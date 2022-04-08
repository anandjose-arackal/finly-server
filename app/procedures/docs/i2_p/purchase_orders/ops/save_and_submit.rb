class Docs::I2P::PurchaseOrders::Ops::SaveAndSubmit < Transactions::API
  step :save
  step :submit

  def save(options, params:, current_user:, **)
    op = Docs::I2P::PurchaseOrders::Ops::Update.(params: params, current_user: current_user)

    unless op.success?
      add_message options, :error, :base, op.messages[:errors]
      return
    end

    options['model'] = op['model']

    add_message options, :success, :base, "Purchase Order Saved"

    true
  end

  def submit(options, params:, current_user:, model:, **)
    submit_params = {
        reviewal_document: model,
        document_reviewer_mappings: params[:document_reviewer_mappings],
        policy_id: params[:policy_id]
    }

    op = Docs::I2P::PurchaseOrders::Ops::Submit.(params: submit_params, current_user: current_user)

    unless op.success?
      add_message options, :error, :base, "Error in Submission"
      add_message options, :error, :base, op.messages[:errors]
    end

    add_message options, :success, :base, "Purchase Order Submitted for Approval"

    true
  end

end