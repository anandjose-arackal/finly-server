class Mobile::V1::CardsController < ApplicationController
  protect_from_forgery with: :null_session

  allow_oauth!
  before_action :authenticate_user!

  respond_to :json

  # params = {action_type: 1, amount: 100, password: 'password', from_account: :virtual_account/:wallet/:card,
  # :to_account: :virtual_account/:wallet/:card }
  def update_balance
    action_type = params[:action_type].to_i rescue nil
    case action_type
      when User::Wallet::Base::ACTIONS[:credit]
        # Value = 1
        @result = User::Wallet::Credit.(current_user, params)
      when User::Wallet::Base::ACTIONS[:debit]
        # Value = 2
        @result = User::Wallet::Debit.(current_user, params)
    end
    if @result.present?
      @result.config[:mobile_api] = true
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
    if @result.present?
      @result.config[:mobile_api] = true
    end
    if @result.present? and @result.success?
      respond response: :success
    else
      respond response: :failure
    end
  end

end
