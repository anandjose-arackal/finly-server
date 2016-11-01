class Autocomplete::Merchant < BaseOperation

  attr_accessor :query, :merchants

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "Invalid parameters"
    end
  end

  def init
    self.query = params[:filter_search] || params[:query]
  end

  def process
    expense_ids = Expense::Index.(user, params).expenses.pluck(:id)

    # todo - see if there's a better way to do this.
    self.response = ManualExpense.merchant_like(query, expense_ids)
    self.response += CardExpense.merchant_like(query, expense_ids)
  end

end