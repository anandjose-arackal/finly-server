class BankTransfer::UsersController < BaseControllers::WebBase

  def index
    @result = BankTransfer::Users::Index.(current_user, params)
    respond
  end

  def count
    @result = BankTransfer::Users::Count.(current_user, params)
    render json: @result.as_json
  end

  def show
    @result = BankTransfer::Users::Show.(current_user, params)
    respond
  end

  def get_managers
    @result = BankTransfer::Users::GetManagers.(current_user, params)
    respond
  end

  def show_transfers
    @result = BankTransfer::Users::Transfers::Show.(current_user, params)
    respond
  end

  def categories
    @result = Category::Invoice::Index.(current_user, params)
    respond
  end

end
