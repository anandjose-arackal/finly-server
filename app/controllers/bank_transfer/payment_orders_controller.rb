# currently this controller is only for admins of companies

class BankTransfer::PaymentOrdersController < BaseControllers::WebBase

  before_action {finly_authorize! :web}

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
