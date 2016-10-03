class AutocompleteController < ApplicationController
  def merchant
    expense_ids = Expense::Index.new(current_user, params).run.expenses.pluck(:id)
    # todo - find out how to search from within the array of merchants, generalize it basically
    query = (params[:filter_search] or params[:query])
    merchants = ManualExpense.merchant_like(query, expense_ids)

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
