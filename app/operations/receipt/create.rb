class Receipt::Create < Receipt::Base
  attr_accessor :receipt, :receipt_params

  def pre_validate
    if params.blank? or user.blank?
      errors << "No user or parameters present."
    end
  end

  def init
    self.receipt_params = create_params
  end


  def process
    self.receipt = user.receipts.build(create_params)
    unless receipt.save
      errors << receipt.errors.full_messages
    end
  end

  def retrieve
    if is_success?
      Receipt::Create::ReceiptPresenter.new(user, receipt: receipt)
    else
      false
    end
  end

  class Receipt::Create::ReceiptPresenter < BaseOperation::BasePresenter
    attr_accessor :receipt

    def initialize(user, params)
      self.receipt = params[:receipt]
    end
  end

  private
  def create_params
    params.require(:receipt).permit!
  end

end