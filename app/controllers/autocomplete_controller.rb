class AutocompleteController < BaseControllers::WebBase

  # def route
  #   result = AutoComplete::Router.dispatch(params[:entity], params: params.to_unsafe_h, current_user: current_user)
  #   if result.success?
  #     render json: {success: true, data: result["model.records.json"]}
  #   else
  #     # todo update format
  #     respond response: :failure, message: "Invalid Request"
  #   end
  # end

  def merchant
    merchants = Autocomplete::Merchant.(current_user, params)
    respond_to do |format|
      format.json {render json: merchants.as_json}
    end
  end

  def user
    @users = User::Team::Index.(current_user, params)
    respond_to do |format|
      format.json {}
    end
  end

  def employees
    @op = Autocomplete::Users.(current_user, params)
    respond_to do |format|
      format.json {}
    end
  end

  def card
    @result = Autocomplete::Cards.(current_user, params)
    respond
  end

  def beneficiaries
    @result = Autocomplete::Beneficiaries.(current_user, params)
    respond
  end

  def vendors
    @result = Autocomplete::Vendors.(current_user, params)
    respond
  end

  def inventory_items
    @result = ItemMaster::Item::Search.(current_user, params)
    respond
  end

  def bbps_billers
    @result = Autocomplete::BbpsBillers.(current_user, params)
    respond
  end
end
