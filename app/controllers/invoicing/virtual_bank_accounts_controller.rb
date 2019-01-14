class Invoicing::VirtualBankAccountsController < BaseControllers::WebBase

  before_action -> { finly_authorize! :web }

  def create
    @result = Invoicing::VirtualBankAccount::Create.(current_user, params)
    respond
  end

  def index
    @result = Invoicing::VirtualBankAccount::Index.(current_user, params)
    respond
  end

  def count
    @result = Invoicing::VirtualBankAccount::Count.(current_user, params)
    render json: @result.count.as_json
  end

  def update
    @result = Invoicing::VirtualBankAccount::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def show
    @result = Invoicing::VirtualBankAccount::Show.(current_user, params)
    respond
  end

  def destroy
    @result = Invoicing::VirtualBankAccount::Destroy.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def deactivate
    @result = Invoicing::VirtualBankAccount::Deactivate.(current_user, params)
    respond
  end

  def reactivate
    @result = Invoicing::VirtualBankAccount::Reactivate.(current_user, params)
    respond
  end

  def show_payments
    @result = Invoicing::VirtualBankAccount::Payments::Show.(current_user, params)
    respond
  end
end
