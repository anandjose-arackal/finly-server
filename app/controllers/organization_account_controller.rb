class OrganizationAccountController < BaseControllers::WebBase



  def policies_list
    @result = Company::Configuration::Show.(current_user, params)
    respond_to do |format|
      format.html {render partial: 'policy_list'}
      format.json {}
    end
  end

  def categories
    # in org account, show all categories irrespective of current app
    RequestStore.store[:organization_account] = true
    @result = Categories::Index.(current_user, params)
    respond
  end

  def departments
    @result = Company::Departments::Index.(current_user, params)
    respond
  end

  def all_expense_types
    @result = ExpenseType.select(:id, :name)
    respond_to do |format|
      format.json {render json: @result.as_json} # Hack to fix JSON Syntax error
    end
  end

  def export_preferences
    @result = Company::Configuration::Show.(current_user, params)
    respond_to do |format|
      format.html {render partial: 'export_preferences'}
      format.json {}
    end
  end

  def show
    @result = Company::Configuration::Show.(current_user, params)

    respond_to do |format|
      format.html {render 'organization_account/show'}
      format.json {render 'organization_account/show'}
    end
  end

  def gst_state_codes
    @codes = State.all
    respond_to do |format|
      format.json {render 'organization_account/gst_state_codes'}
    end
  end

  def sidebar_menu_config
    @feature_subscriptions = current_user.company.feature_subscription
    respond_to do |format|
      #todo vivek : Add feature subscription for expense tds / tax
      format.json {}
    end
  end

  def transfer_modes
    modes = TransferMode.all
    company_modes = current_user.company.transfer_modes.as_json
    @result = {
      success: true,
      messages: {
          error: [],
          failure: [],
          success: [],
          message: [],
          notice: []
      },
      transfer_modes: modes,
      company_modes: company_modes,
    }
    respond_to do |format|
      format.json {render json: @result.as_json}
    end
  end

  def create_transfer_modes
    @result = Company::TransferModes::Create.(current_user, params)
    respond_success_failure
  end

  def destroy_transfer_modes
    @result = Company::TransferModes::Destroy.(current_user, params)
    respond_success_failure
  end

end
