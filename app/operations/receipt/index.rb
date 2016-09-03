class Receipt::Index < Receipt::Base
  attr_accessor :receipts

  def process
    self.receipts = user.receipts.without_parent
  end

  def retrieve
    if is_success?
      Receipt::Index::ReceiptsPresenter.new(user, {receipts: receipts})
    else
      false
    end
  end

  class Receipt::Index::ReceiptsPresenter < BaseOperation::BasePresenter
    attr_accessor :receipts

    def initialize(user, params)
      self.receipts = params[:receipts]
    end
  end

end