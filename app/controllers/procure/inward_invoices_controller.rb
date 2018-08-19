class Procure::InwardInvoicesController < ApplicationController

  before_action -> {finly_authorize! :web}

  # this action is to create one from a purchase order
  def create_from_po
    @result = Procurements::ProcureInwardInvoices::CreateFromPO.(current_user, params)
    # if @result.success?
    #   respond response: :success, message: @result.messages[:success]
    # else
    #   respond response: :failure, message: @result.messages[:error]
    # end
    respond
  end

  # this action is to create one from scratch
  def create

  end

  def show
    @result = Procurements::ProcureInwardInvoices::Show.(current_user, params)
    respond
  end

end