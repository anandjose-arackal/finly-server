class StatementsController < ApplicationController

  before_action :authenticate_user!

  def index

  end

  def show
    @result = EmployeeStatement::Show.(current_user, params)
    if @result.success?
      respond_to do |format|
        format.json {render json: @result.items.as_json}
      end
    else
      respond
    end
  end

  def summary
    @result = EmployeeStatement::Summary.(current_user, params)
    if @result.success?
      respond_to do |format|
        format.json {render json: @result.items.as_json}
      end
    else
      respond
    end
  end

end
