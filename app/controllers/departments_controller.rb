class DepartmentsController < ApplicationController

  before_action -> { finly_authorize! :web }

  def index
    @result = Company::Departments::Index.(current_user, params)
    respond
  end

  # todo

  def create
    @result = Company::Department::Create.(current_user, params)
    repsond
  end

  def show
    @result = Company::Department::Show.(current_user, params)
    repsond
  end

  def update
    @result = Company::Department::Update.(current_user, params)
    repsond
  end

  def destroy
    @result = Company::Department::Destroy.(current_user, params)
    repsond
  end
end