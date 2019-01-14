class Invoicing::CustomersController < BaseControllers::WebBase


  def create
    @result = Invoicing::Customer::Create.(current_user, params)
    respond
  end

  def index
    @result = Invoicing::Customer::Index.(current_user, params)
    respond
  end

  def count
    @result = Invoicing::Customer::Count.(current_user, params)
    render json: @result.count.as_json
  end

  def update
    @result = Invoicing::Customer::Update.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def show
    @result = Invoicing::Customer::Show.(current_user, params)
    respond
  end

  def destroy
    @result = Invoicing::Customer::Destroy.(current_user, params)
    respond
  end

  def payments
    @result = Invoicing::Customer::Payments::Index.(current_user, params)
    respond
  end

  def payments_count
    @result = Invoicing::Customer::Payments::Count.(current_user, params)
    render json: @result.count.as_json
  end

  def invoices
    @result = Invoicing::Customer::Invoices::Index.(current_user, params)
    respond
  end

  def invoices_count
    @result = Invoicing::Customer::Invoices::Count.(current_user, params)
    render json: @result.count.as_json
  end

  def virtual_bank_accounts
    @result = Invoicing::Customer::VirtualBankAccounts::Index.(current_user, params)
    respond
  end

  def create_virtual_account
    @result = Invoicing::Customer::VirtualBankAccounts::Create.(current_user, params)
    respond
  end

  def import
    @result = Invoicing::Customer::Import.(current_user, params)
    respond
  end

end
