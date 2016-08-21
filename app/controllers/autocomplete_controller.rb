class AutocompleteController < ApplicationController
  def merchant
    merchants = ManualExpense.where('lower(merchant) LIKE ?', "%#{params[:query].downcase}%").pluck(:merchant)

    respond_to do |format|
      format.json {render json: merchants.as_json }
    end
  end
end
