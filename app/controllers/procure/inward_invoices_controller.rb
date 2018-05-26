class Procure::InwardInvoicesController < ApplicationController

  before_action -> {finly_authorize! :web}

  # this action is to create one from a purchase order
  def create_from_po
    @result = Procurements::InwardInvoices::CreateFromPO.(current_user, params)
    respond_success_failure
  end

  # this action is to create one from scratch
  def create

  end

end