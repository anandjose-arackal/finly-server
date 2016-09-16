class Receipt::Create < Receipt::Base
  attr_accessor :receipt, :receipt_params

  def pre_validate
    if params.blank? or user.blank?
      messages[:error] << "No user or parameters present."
    end
  end

  def init
    self.receipt_params = create_params
  end


  def process
    self.receipt = user.receipts.build(create_params)
    unless receipt.save
      messages[:error] << receipt.errors.full_messages
    end
  end

  def post_process
    messages[:success] = "Receipt added."
  end

  def success
    Receipt::Create::ReceiptPresenter.new(user, {receipt: receipt}, messages)
  end

  class Receipt::Create::ReceiptPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :receipt

    def init
      self.receipt = params[:receipt]
    end
  end

  private
  def create_params
    params.require(:receipt).permit(:image, :note)
  end

end