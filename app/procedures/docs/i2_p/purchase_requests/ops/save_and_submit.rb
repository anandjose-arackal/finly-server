class Docs::I2P::PurchaseRequests::Ops::SaveAndSubmit < Transactions::API
  step :save
  step :submit

  def save(options, params:, current_user:, **)
    op = Docs::I2P::PurchaseRequests::Ops::Update.(params: params, current_user: current_user)

    unless op.success?
      add_message options, :error, :base, op.messages[:errors]
      return
    end

    options['model'] = op['model']

    add_message options, :success, :base, "Purchase Request Saved"

    true
  end

  def submit(options, params:, current_user:, model:, **)
    submit_params = {
        reviewal_document: model,
        document_reviewer_mappings: params[:document_reviewer_mappings],
        policy_id: params[:policy_id]
    }

    op = Docs::I2P::PurchaseRequests::Ops::Submit.(params: submit_params, current_user: current_user)

    if op.success?
      purchase_request = options[:model]
      purchase_request_status = purchase_request&.status&.name

      if purchase_request_status.present?
        if purchase_request_status == 'auto_approved'
          trail_action = 'auto_approve'
        elsif purchase_request_status == 'awaiting_approval'
          trail_action = 'submit'
        end
        purchase_request.purchase_request_items.each do |item|
          item.status_id = PurchaseRequestItemStatus.id_for(purchase_request&.status&.name&.to_sym)
          item.rejected = false
          if item.save
            trail = item.trails.create(action_user: options[:user], action_id: TrailAction.id_for(trail_action))
          end
        end
      else
        raise
      end
    else
      add_message options, :error, :base, "Error in Submission"
      add_message options, :error, :base, op.messages[:errors]
    end

    add_message options, :success, :base, "Purchase Request Submitted for Approval"

    true
  end

end