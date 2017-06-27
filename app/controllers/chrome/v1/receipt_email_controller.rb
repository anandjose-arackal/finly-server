class Chrome::V1::ReceiptEmailController < ApplicationController

  before_action :authenticate_user!
  allow_oauth!

  def show
    @result = Receipt::ReceiptEmails::Show.(current_user, params)
  end

end
