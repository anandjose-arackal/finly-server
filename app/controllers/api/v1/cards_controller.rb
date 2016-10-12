class Api::V1::CardsController < ApplicationController
  protect_from_forgery with: :null_session

  allow_oauth!
  before_action :authenticate_user!

  respond_to :json

  # params = {action_type: 1, amount: 100, password: 'password'}
  def update_balance
    action_type = params[:action_type].to_i rescue nil
    case action_type
      when User::PrepaidCard::Funds::Base::ACTIONS[:credit]
        # Credit from company credits
        @result = User::PrepaidCard::Funds::Credit.(current_user, params)
      when User::PrepaidCard::Funds::Base::ACTIONS[:debit]
        # Debit from company credits
        @result = User::PrepaidCard::Funds::Debit.(current_user, params)
      when User::PrepaidCard::Funds::Base::ACTIONS[:transfer]
        # Transfer from card to users card
        @result = User::PrepaidCard::Funds::Transfer.(current_user, params)
      when User::PrepaidCard::Funds::Base::ACTIONS[:withdraw]
        # Withdraw from card to users card
        @result = User::PrepaidCard::Funds::Withdraw.(current_user, params)
      else
        @result = BaseOperation::BasePresenter::FailurePresenter.new(current_user, params, {error: ['Invalid Action Type']})
    end
    if @result.present? and @result.success?
      respond response: :success
    else
      respond response: :failure
    end
  end

  # params = { disable_note: 'why am i disabling this card', action_type: 1, password: 'password' }
  def update_status
    status_type = params[:status_type].to_i rescue nil
    case status_type
      when 0
        # Block
        @result = User::PrepaidCard::Block.(current_user, params)
      when 1
        # Unblock
        @result = User::PrepaidCard::Unblock.(current_user, params)
      else
        @result = BaseOperation::BasePresenter::FailurePresenter.new(current_user, params, {error: ['Invalid Status Type']})
    end
    if @result.present? and @result.success?
      respond response: :success
    else
      respond response: :failure
    end
  end

end