class Receipt::Index < Receipt::Base
  attr_accessor :receipts

  def process
    if personal_view?
      self.receipts = user.receipts.without_parent
    else
      expense_presenter = Expense::Index.(user, params)
      if expense_presenter.success?
        expense_ids = expense_presenter.expenses.pluck(:id)
        self.receipts = Receipt.with_expense_id(expense_ids)
      else
        add_message :error, expense_presenter.messages[:error]
        return
      end
    end
  end

  def success
    params[:receipts] = receipts
    Receipt::Index::ReceiptsPresenter.new(user, params, messages)
  end

  class Receipt::Index::ReceiptsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    include HasScope
    attr_accessor :receipts, :categories, :count, :paginated_receipts

    has_scope :filter_date, using: [:from, :to], type: :hash

    def init
      self.receipts = apply_scopes(params[:receipts])
      self.count = self.receipts.count
      self.paginated_receipts = self.receipts.paginate(page: params[:page], per_page: 32) rescue nil
      self.categories = user.company.categories.active
    end
  end

end