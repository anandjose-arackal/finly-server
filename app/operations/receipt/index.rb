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
    attr_accessor :receipts

    def init
      self.receipts = params[:receipts].paginate(page: params[:page], per_page: 30) rescue nil
    end
  end

end