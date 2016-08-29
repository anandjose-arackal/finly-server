class Receipt::Base < BaseOperation

  attr_accessor :receipt, :receipt_params

  def authorized_user_types
    [:employee]
  end

  def create_params
    params.require(:receipt).permit(:image)
  end
  
end