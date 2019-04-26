class Procure::PurchaseRequestsController < ApplicationController

  before_action -> { finly_authorize! :web}

  def index
    @result = Procurements::PurchaseRequests::Index.(current_user, params)
    respond
  end

  def show
    @result = Procurements::PurchaseRequests::Show.(current_user, params)
    respond
  end

  def create
    @result = Procurements::PurchaseRequests::Create.(current_user, params)
    respond
  end

  def update
    @result = Procurements::PurchaseRequests::Update.(current_user, params)
    respond
  end

  def destroy
    @result = Procurements::PurchaseRequests::Destroy.(current_user, params)
    respond
  end

  # def create_and_submit
  #   @result = Procurements::PurchaseRequests::CreateAndSubmit.(current_user, params)
  #   respond
  # end

  def save_and_submit
    @result = Procurements::PurchaseRequests::SaveAndSubmit.(current_user, params)
    respond
  end

  def submit
    @result = Procurements::PurchaseRequests::Submit.(current_user, params)
    respond
  end

  def retract
    @result = Procurements::PurchaseRequests::Retract.(current_user, params)
    respond
  end

  def reject
    @result = Procurements::PurchaseRequests::Reject.(current_user, params)
    respond
  end

  def approve
    @result = Procurements::PurchaseRequests::Approve.(current_user, params)
    respond
  end

  def unapprove
    @result = Procurements::PurchaseRequests::Unapprove.(current_user, params)
    respond
  end

  def take_control
    @result = Procurements::PurchaseRequests::TakeControl.(current_user, params)
    respond
  end

  def return_control
    @result = Procurements::PurchaseRequests::ReturnControl.(current_user, params)
    respond
  end

  def edit_config
    @result = Procurements::PurchaseRequests::PurchaseRequestEditConfig.(current_user, params)
    respond
  end

  def actions_configuration
    @result = ActionsManager::Processor.(current_user, params)
    respond
  end

  def approved_items
    @result = Procurements::PurchaseRequests::ApprovedItems.(current_user, params)
    respond
    # respond_to do |format|
    #   format.json
    # end
  end

  # Bulk rejection of approved items
  def bulk_reject_approved_items
    @result = Procurements::PurchaseRequests::RejectApprovedItems.(current_user, params)
    respond
  end

  def issue_from_inventory
    @result = Procurements::PurchaseRequests::IssueFromInventory.(current_user, params)
    respond
  end

  def count
    @result = Procurements::PurchaseRequests::Count.(current_user, params)
    respond
  end

  def bulk_approve
    @result = Procurements::PurchaseRequests::BulkApprove.(current_user, params)
    respond
  end

  def bulk_take_control
    @result = Procurements::PurchaseRequests::BulkTakeControl.(current_user, params)
    respond
  end

  def bulk_reject
    @result = Procurements::PurchaseRequests::BulkReject.(current_user, params)
    respond
  end

  def bulk_upload_items
    @result = Procurements::PurchaseRequests::BulkUploadLineItems.(current_user, params)
    if @result.success?
      respond_to do |format|
        format.json {
          render 'bulk_upload_items_success'
        }
      end
    else
      respond_to do |format|
        format.json {
          render 'bulk_upload_items_failure'
        }
      end
    end
  end

  def template_bulk_import_items
    @result = Procurements::PurchaseRequests::GenerateImportSample.(current_user, params)
    respond
  end

end