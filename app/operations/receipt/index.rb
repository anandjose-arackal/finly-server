class Receipt::Index < Receipt::Base
  attr_accessor :receipts

  def process
    self.receipts = user.receipts.without_parent
  end

  def success
    params[:receipts] = receipts
    Receipt::Index::ReceiptsPresenter.new(user, params, messages)
  end

  class Receipt::Index::ReceiptsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    include HasScope
    attr_accessor :receipts, :categories

    has_scope :filter_date, using: [:from, :to], type: :hash

    def init
      self.receipts = apply_scopes(params[:receipts]).paginate(page: params[:page], per_page: 32) rescue nil
      self.categories = user.company.categories.active
    end
  end

end