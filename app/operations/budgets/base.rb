class Budgets::Base < BaseOperation
  attr_accessor :budget, :budget_params

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, 'Invalid parameters passed'
    end
    if params[:budget].blank?
      add_message :error, 'You have not provided any details to create a budget'
      return
    end
  end


  private
  def create_budget_params
    params.require(:budget).permit(:name, :period_id, :start_date, :end_date,
                                   :budgetable_id, :budgetable_type,
                                   budget_amount_attributes: [:value, :currency_id]
    )
  end

  def update_budget_params
    params.require(:budget).permit(:id, :name, :period_id, :start_date, :end_date,
                                   :budgetable_id, :budgetable_type,
                                   budget_amount_attributes: [:id, :value, :currency_id]
    )
  end
end