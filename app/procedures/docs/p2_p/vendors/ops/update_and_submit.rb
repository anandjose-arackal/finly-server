class Docs::P2P::Vendors::Ops::UpdateAndSubmit < Transactions::API

  step :update
  step :submit


  def update(options, params:, current_user:, **)
    op = Docs::P2P::Vendors::Ops::Update.(params: params, current_user: current_user)


    unless op.success?
      add_message options, :error, :base, op.messages[:errors]
      return
    end

    options['model'] = op['model']

    true
  end

  def submit(options, params:, current_user:, model:, **)
    submit_params = {
        reviewal_document: model,
        document_reviewer_mappings: params[:document_reviewer_mappings]
    }
    op = Docs::P2P::Vendors::Ops::Submit.(params: submit_params, current_user: current_user)

    unless op.success?
      add_message options, :error, :base, op.messages[:errors]
    end

    true
  end

end