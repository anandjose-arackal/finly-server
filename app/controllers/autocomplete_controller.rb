class AutocompleteController < ApplicationController
  def merchant
    expense_presenter = Expense::Index.new(current_user, UserRole.employee_id).run
    # todo - find out how to search from within the array of merchants
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
