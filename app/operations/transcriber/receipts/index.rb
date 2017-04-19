class Transcriber::Receipts::Index < BaseOperation

  attr_accessor :receipts, :companies

  class Transcriber::Receipts::Index::TranscriberPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :receipts, :categories, :companies, :users

    # scopes for filters
    has_scope :filter_user

    def init
      self.receipts = params[:receipts]
      self.receipts = apply_scopes(receipts, params)
    end

  end

  def pre_validate
    super()
  end

  def init
    id = params[:company_id] || params[:filter_company_id]
    if id.present?
      self.companies = Company.ocr_enabled.with_id(id)
    else
      self.companies = Company.ocr_enabled
    end
    self.receipts = []
  end

  def authorize

  end

  def process
    user_ids = []
    companies.each do |company|
      user_ids += company.users.pluck(:id)
    end
    if params[:filter_parent] == '1'
      self.receipts = Receipt.untranscribed.without_parent.with_user_id(user_ids)
    elsif params[:filter_parent] == '2'
      expense_ids = Expense.transcribed.with_user_id(user_ids).pluck(:id)
      self.receipts = Receipt.with_expense_id(expense_ids)
    end
  end


  def success
    params[:receipts] = receipts
    Transcriber::Receipts::Index::TranscriberPresenter.new(user, params, messages)
  end
end