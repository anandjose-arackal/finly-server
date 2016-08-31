class Receipt::Index < Receipt::Base

  class Receipt::Index::ReceiptsPresenter < Receipt::Base::ReceiptPresenter

    attr_accessor :receipts

    def initialize(user, params)
      self.receipts = params[:receipts]
    end
  end

  def self.call(user, params)
    self.new(user, params).run
  end

  def process
    self.receipts = user.receipts.without_parent
  end

  def retrieve
    if is_success?
      receipts_presenter = Receipt::Index::ReceiptsPresenter.new(user, {receipts: receipts})
      return receipts_presenter
    else
      return false
    end
  end

end