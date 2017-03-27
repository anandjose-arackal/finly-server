class Transcriber::Receipts::Index < BaseOperation

  attr_accessor :receipts, :company

  class Transcriber::Receipts::Index::TranscriberPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :receipts, :categories, :company

    # scopes for filters
    has_scope :filter_parent

    def init
      self.receipts = params[:receipts]
      self.receipts = apply_scopes(receipts, params)
      self.company = params[:company]
      self.categories = params[:categories]
    end

  end

  def pre_validate

  end

  def init
    id = params[:id] || params[:company_id]
    self.company = Company.find_by(id)
    self.receipts = []
  end

  def authorize
    unless company
      raise_unauthorized_exception
    end
  end

  def process
    user_ids = []
    company.users.each do |user|
      user_ids << user.id
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