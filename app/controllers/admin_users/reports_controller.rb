class AdminUsers::ReportsController < BaseControllers::PublicBase

  def show
    @result = Admin::Reports::Show.(current_user, params)
    respond
  end

  def index
    @result = Admin::Reports::Index.(current_user, params)
    respond
  end
end
