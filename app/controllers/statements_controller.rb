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
  def company_balance_summary
    @result = Company::Statement::BalanceSummary.(current_user, params)
    respond_to do |format|
      format.json {}
    end
  end

  def company_transactions_summary
    @result = Company::Statement::TransactionsSummary.(current_user, params)
    respond_to do |format|
      format.json {}
    end
  end

  def company_policies_summary
    @result = Company::Statement::PolicyExpenses.(current_user, params)
    # debugger
    respond_to do |format|
      format.json {}
    end
  end
end
