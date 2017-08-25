# currently this controller is only for admins of companies

class BankTransfer::PaymentOrdersController < ApplicationController

  before_action {finly_authorize! :web}

  # def process_file
  #   @result = BankTransfer::YesBank::ParseFile.(current_user, params)
  #   respond
  # end

  # def create
  #   @result = BankTransfer::YesBank::Create.(current_user, params)
  #   respond
  # end

  # def process_account_ids
  #   @result = BankTransfer::YesBank::ProcessFromAccountIds.(current_user, params)
  #   if @result&.success?
  #     render 'process_file'
  #   else
  #     respond response: :failure, message: @result.messages[:error]
  #   end
  # end
  #
  # def account_details
  #   @result = BankTransfer::YesBank::AccountDetails.(current_user, params)
  #   respond
  # end

  def index
    @result = BankTransfer::YesBank::Index.(current_user, params)
    respond
  end

  def count
    @result = BankTransfer::YesBank::Count.(current_user, params)
    render json: @result.as_json
  end

  def show
    @result = BankTransfer::YesBank::Show.(current_user, params)
    respond
  end

  # the operation used to cancel the particular payment order
  def destroy
    @result = BankTransfer::YesBank::Cancel.(current_user, params)
    respond
  end

  # returns the Yes Bank Account Balance for the given account
  def balance
    @result = BankTransfer::Users::Balance.(current_user, params)
    respond
  end
  #
  # def update_details
  #   @result = BankTransfer::YesBank::Update.(current_user, params)
  #   respond
  # end
end
