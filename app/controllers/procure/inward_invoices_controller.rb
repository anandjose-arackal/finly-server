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

  def destroy
    @result = Procurements::Invoices::Destroy.(current_user, params)
    respond
  end

  # Templates
  def template_create
    @result = Procurements::Invoices::Templates::Create.(current_user, params)
    respond response: @result.success? ? :success : :failure
  end

  def template_apply
    @result = Procurements::Invoices::Templates::Apply.(current_user, params)
    respond
  end

  def template_index
    @result = Procurements::Invoices::Templates::Index.(current_user, params)
    respond
  end

  def template_show
    @result = Procurements::Invoices::Templates::Show.(current_user, params)
    respond
  end

  def template_update
    @result = Procurements::Invoices::Templates::Update.(current_user, params)
    respond response: @result.success? ? :success : :failure
  end

  def template_destroy
    @result = Procurements::Invoices::Templates::Destroy.(current_user, params)
    respond response: @result.success? ? :success : :failure
  end

  # Template for bulk creation of NON PO invoices
  def import_template
    @result = Procurements::Invoices::ImportTemplate.(current_user, params)
    respond
  end

end