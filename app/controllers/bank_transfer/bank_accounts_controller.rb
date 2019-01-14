class BankTransfer::BankAccountsController < BaseControllers::WebBase

  before_action {finly_authorize! :web}

  def create
    @result = BankTransfer::BankAccounts::Create.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def index
    @result = BankTransfer::BankAccounts::Index.(current_user, params)
    respond
  end

  def count
    @result = BankTransfer::BankAccounts::Count.(current_user, params)
    render json: @result
  end

  def show
  end

  def destroy
    @result = BankTransfer::BankAccounts::Destroy.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update
    @result = BankTransfer::BankAccounts::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def disable
    @result = BankTransfer::BankAccounts::Disable.(current_user, params)
    respond
  end


end
