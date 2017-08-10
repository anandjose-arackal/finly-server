class BankTransfer::VendorsController < ApplicationController

  before_action {finly_authorize! :web}

  def create
    @result = BankTransfer::Vendor::Create.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update
    @result = BankTransfer::Vendor::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def index
    @result = BankTransfer::Vendor::Index.(current_user, params)
    respond
  end

  def show
    @result = BankTransfer::Vendor::Show.(current_user, params)
    respond
  end

end
