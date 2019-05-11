class Chrome::V1::ReceiptEmailController < BaseControllers::ChromeBase


  def show
    @result = Receipt::ReceiptEmails::Show.(current_user, params)
  end

end
