class DepartmentsController < ApplicationController

  before_action -> { finly_authorize! :web }

  def index
    @result = Company::Departments::Index.(current_user, params)
    respond
  end

  # todo

  def create

  end

  def show

  end

  def update

  end
end