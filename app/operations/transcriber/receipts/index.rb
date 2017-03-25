class Transcriber::Receipts::Index < BaseOperation

  attr_accessor :receipts, :company

  class Transcriber::Receipts::Index::TranscriberPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :receipts, :categories, :company

    def init
      self.receipts = params[:receipts]
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
    company.users.each do |user|
      self.receipts += user.receipts
    end
  end

  def success
    params[:receipts] = receipts
    params[:company] = company
    params[:categories] = company.categories.active
    Transcriber::Receipts::Index::TranscriberPresenter.new(user, params, messages)
  end
end