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

  # Company Statements
  def company_statements
    @result = Company::Statement::Summary.(current_user, params)
    respond_to do |format|
      format.html {render partial: 'company_statements'}
    end
  end

  def company_summary
    @result = Company::Statement::Summary.(current_user, params)
    respond_to do |format|
      format.html {render partial: 'company_summary'}
    end
  end

  def policies_summary
    @result = Company::Statement::PolicyExpenses.(current_user, params)
    # debugger
    respond_to do |format|
      format.html {render partial: 'policies_summary'}
    end
  end
end
