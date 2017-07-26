class Receipt::Show < Receipt::Base
  attr_accessor :receipt

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
    id = (params[:id] or params[:receipt_id])
    self.receipt = receipts_presenter.receipts.find_by_id(id)
  end

  def validate
    if self.receipt.blank?
      add_message :error, 'Receipt not found'
    end
  end

  def success
    params[:receipt] = self.receipt
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