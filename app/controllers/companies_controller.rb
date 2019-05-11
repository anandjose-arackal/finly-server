class CompaniesController < BaseControllers::WebBase


  def notify
    # todo
    @result = Company::ItzCashVirtualAccount::Balance.(current_user, params)
    if @result.success?
      @company_balance = @result.balance
      @company = @result.company
    else
      @company_balance = 0
      @company = nil
    end
    respond
  end

  def add_balance
    @result = Company::AddBalance.(current_user, params)
    respond
  end

  def load_options
    @result = Company::LoadOptions.(current_user, params)
    respond
  end

  def categories_and_custom_fields

  end
end
