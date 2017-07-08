class AdminUsers::ExpensesController < ApplicationController


  before_action :doorkeeper_authorize!

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