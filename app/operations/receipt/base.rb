class Receipt::Base < BaseOperation

  attr_accessor :receipt, :receipt_params

  class Receipt::Base::ReceiptPresenter < BaseOperation::BasePresenter

    attr_accessor :receipt

    def initialize(user, params)
      self.receipt = params[:receipt]
    end

  end

  def authorized_user_types
    [:employee]
  end

  def create_params
    params.require(:receipt).permit(:image)
  end
  
end