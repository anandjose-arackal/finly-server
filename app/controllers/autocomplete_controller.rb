class AutocompleteController < ApplicationController
  def merchant
    expense_ids = Expense::Index.new(current_user, UserRole.employee_id).run.expenses.pluck(:id)
    # todo - find out how to search from within the array of merchants, generalize it basically
    merchants = ManualExpense.merchant_like(params[:query], expense_ids)

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
