class Receipt::Export < Receipt::Base
  attr_accessor :receipts

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    unless params&.dig(:id).present? or params&.dig(:receipt_id).present?
      add_message :error, 'Receipt not found'
    end
  end

  def init
    receipts_presenter = Receipt::Index.(user, params)
    unless receipts_presenter.success?
      add_message :error, receipts_presenter.messages[:error]
      return
    end
    self.receipts = receipts_presenter.receipts
  end

  def validate
    if self.receipts.blank?
      add_message :error, 'Receipt not found'
    end
  end

  def success
    params[:receipts] = self.receipts
    Receipt::Show::ReceiptsPresenter.new(user, params, messages)
  end

  class Receipt::Show::ReceiptsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :receipt, :categories

    def init
      self.receipt = params[:receipt]
      self.categories = user.company.categories.active
    end
  end

end