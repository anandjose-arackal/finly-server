class Transcriber::Receipts::Index < BaseOperation

  attr_accessor :receipts, :company

  class Transcriber::Receipts::Index::TranscriberPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :receipts, :categories, :company, :users

    # scopes for filters
    has_scope :filter_parent
    has_scope :filter_user
    has_scope :filter_company

    def init
      self.receipts = params[:receipts]
      self.receipts = apply_scopes(receipts, params)
      self.company = params[:company]
      self.categories = params[:categories]
      self.users = company.users
    end

  end

  def pre_validate
    super()
  end

  def init
    self.companies = Company.ocr_enabled
    self.receipts = []
  end

  def authorize

  end

  def process
    user_ids = []
    companies.each do |company|
      user_ids += company.users.pluck(:id)
    end
    self.receipts = Receipt.untranscribed.with_user_id(user_ids)
  end

  def success
    params[:receipts] = receipts
    params[:company] = company
    params[:categories] = company.categories.active
    Transcriber::Receipts::Index::TranscriberPresenter.new(user, params, messages)
  end
end