class OrganizationAccountController < BaseControllers::WebBase



  def policies_list
    @result = Company::Configuration::Show.(current_user, params)
    respond_to do |format|
      format.html {render partial: 'policy_list'}
      format.json {}
    end
  end

  def categories
    @result = Categories::Index.(current_user, params)
    respond
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
    @codes = GstStateCode.all
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

end
