class AutocompleteController < ApplicationController
  def merchant
    merchants = ManualExpense.merchant_like(params[:query])

    respond_to do |format|
      format.json {render json: merchants.as_json }
    end
  end

  def user
    @users = User.filter_search(params[:query]).select(:id, :name)

    respond_to do |format|
      # format.json {render json: users.to_a.as_json }
      format.json {}
    end
  end
end
