class AdminUsers::ExpensesController < ApplicationController

  before_action :authenticate_user!
  allow_oauth!

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