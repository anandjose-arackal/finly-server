class AutocompleteController < ApplicationController
  allow_oauth!
  def merchant
    merchants = Autocomplete::Merchant.(current_user, params)

    respond_to do |format|
      format.json {render json: merchants.as_json }
    end
  end

  def user
    @users = User::Team::Index.(current_user, params)
    # scoping the search to within the particular user's team
    #  = team.filter_search(params[:query]).select(:id, :name) rescue nil
    respond_to do |format|
      format.json {}
    end
  end
end
