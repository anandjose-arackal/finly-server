class Docs::P2P::CreditNotes::Ops::Update < Transactions::API

  # schema do
  #   params do
  #     # Todo filled from user
  #     required(:subscription) do
  #       required(:subscription_pocs) do
  #         hash do
  #           required(:user_id).filled
  #         end
  #       end
  #     end
  #   end
  # end

  step :set_default_params
  step Model(CreditNote, :find_by)
  step Policy::Pundit(Docs::P2P::CreditNotes::Authorizer, :update?)
  step Contract::Build(constant: Docs::P2P::CreditNotes::Contracts::Update)
  step Contract::Validate(key: 'credit_note')

  step Contract::Persist()
  fail :check2
  step :test
  step Transactions::Messages::SuccessMessage('Successfully Updated Utility Bill Master')

  def check(options, **)
  end

  def check2(options, **)
  end

  def test(options, **)
    true
  end

  def set_default_params(options, params:, current_user:, **)
    params[:credit_note][:current_user] = current_user
  end
end