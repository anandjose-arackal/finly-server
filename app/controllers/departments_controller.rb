class DepartmentsController < BaseControllers::WebBase


  def index
    @result = Company::Departments::Index.(current_user, params)
    respond
  end

  def all_users
    @result = Company::Users.(current_user, params)
    respond
  end

  # todo

  def create
    @result = Company::Departments::Create.(current_user, params)
    respond
  end

  def show
    @result = Company::Departments::Show.(current_user, params)
    respond
  end

  def update
    @result = Company::Departments::Update.(current_user, params)
    respond
  end

  def destroy
    @result = Company::Departments::Destroy.(current_user, params)
    respond
  end
end
