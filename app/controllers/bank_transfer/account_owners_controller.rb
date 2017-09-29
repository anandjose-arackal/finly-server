class BankTransfer::AccountOwnersController < ApplicationController

  before_action {finly_authorize! :web}

  def create
    @result = BankTransfer::AccountOwners::Create.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update
    @result = BankTransfer::AccountOwners::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def index
    @result = BankTransfer::AccountOwners::Index.(current_user, params)
    respond
  end

  def count
    @result = BankTransfer::AccountOwners::Count.(current_user, params)
    render json: @result.as_json
  end

  def show
    @result = BankTransfer::AccountOwners::Transfers::Show.(current_user, params)
    respond
  end

end
