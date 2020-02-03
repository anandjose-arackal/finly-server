class Docs::P2P::CreditNotes::Ops::UpdateAndSubmit < Transactions::API

  step :update

  step :submit

  def update(options, params:, current_user:, **)
    op = Docs::P2P::CreditNotes::Ops::Update.(params: params, current_user: current_user)

    op.messages.each do |key, val|
      next if key == :errors_meta
      add_message options, key, :base, val
    end

    op.success?
  end

  def submit(options, params:, current_user:, **)
    params[:aasm_event] = :submit
    op = Docs::P2P::CreditNotes::Ops::Review.(params: params, current_user: current_user)

    op.messages.each do |key, val|
      next if key == :errors_meta
      add_message options, key, :base, val
    end

    op.success?
  end
end