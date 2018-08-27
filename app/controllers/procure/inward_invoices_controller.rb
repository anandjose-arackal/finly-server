class Procure::InwardInvoicesController < ApplicationController

  before_action -> {finly_authorize! :web}

  # this action is to create one from a purchase order
  def create_from_po
    @result = Procurements::Invoices::CreateFromPO.(current_user, params)
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
    @result = Procurements::Invoices::Show.(current_user, params)
    respond
  end

  def submit
    @result = Procurements::Invoices::Submit.(current_user, params)
    respond
  end

  def approve
    @result = Procurements::Invoices::Approve.(current_user, params)
    respond
  end

  def reject
    @result = Procurements::Invoices::Reject.(current_user, params)
    respond
  end

  def retract
    @result = Procurements::Invoices::Retract.(current_user, params)
    respond
  end

  def close
    @result = Procurements::Invoices::Close.(current_user, params)
    respond
  end

end