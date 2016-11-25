class StatementsController < ApplicationController

  before_action :authenticate_user!

  def index
  end

  def show
    @result = EmployeeStatement::Show.(current_user, params)
    respond_to do |format|
      format.json {render json: @result.items.as_json}
    end
  end

  def summary
    @result = EmployeeStatement::Summary.(current_user, params)
    respond_to do |format|
      format.json {render json: @result.items.as_json}
    end
  end

end
