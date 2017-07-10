class Chrome::V1::ReceiptEmailController < ApplicationController

  before_action -> { doorkeeper_authorize! :chrome}

  def show
    @result = Receipt::ReceiptEmails::Show.(current_user, params)
  end

end
