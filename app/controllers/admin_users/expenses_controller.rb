class AdminUsers::ExpensesController < BaseControllers::AdminBase


  before_action -> { finly_authorize! :admin}

  def index
    @result = Admin::Expenses::Index.(current_user, params)
    respond
  end

  def show

  end

  def create

  end

  def update
    @result = Admin::Expenses::Update.(current_user, params)
    respond
  end

end
