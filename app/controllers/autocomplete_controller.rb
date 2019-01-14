class AutocompleteController < BaseControllers::WebBase
  def merchant
    merchants = Autocomplete::Merchant.(current_user, params)
    respond_to do |format|
      format.json {render json: merchants.as_json }
    end
  end

  def user
    @users = User::Team::Index.(current_user, params)
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
    @result = Invoicing::InventoryLineItem::Search.(current_user, params)
    respond
  end
end
