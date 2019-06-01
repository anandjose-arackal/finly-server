class StatementsController < BaseControllers::WebBase

  set_tokens_in_header :export

  def index
  end

  def show
    @result = Statements::Show.(current_user, params)
    respond
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

  def user_summary
    @result = Statements::Team::Summary.(current_user, params)
    respond
  end

  def user_summary_export
    @result = Statements::Team::Export.(current_user, params)
    respond
  end

  # Company Statements
  def company_balance_summary
    @result = ::Company::Statement::BalanceSummary.(current_user, params)
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
    respond_to do |format|
      format.json {}
    end
  end

  def export
    @result = Statements::AsSpreadsheet.(current_user, params)
    respond
  end

end
