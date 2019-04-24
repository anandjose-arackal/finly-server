class VendorsController < ApplicationController
  before_action -> { finly_authorize! :web }

  def filter_config
    @result = Vendors::FilterConfig.(current_user, params)
    respond
  end

  def index
    params[:non_deleted] = true
    params[:authorized] = true
    @result = Vendors::Index.(current_user, params)
    respond
  end

  def show
    params[:non_deleted] = true
    @result = Vendors::Show.(current_user, params)
    respond
  end

  def procurements
    @result = Vendors::Support::Procurements.(current_user, params)
    respond
  end

  def transactions
    @result = Vendors::Support::Transactions.(current_user, params)
    respond
  end

  def new_vendor_config
    @result = Vendors::NewVendorConfig.(current_user, params)
    respond
  end

  def create
    @result = Vendors::Create.(current_user, params)
    respond
  end

  def create_and_submit
    @result = Vendors::CreateAndSubmit.(current_user, params)
    respond
  end

  def update
    @result = Vendors::Update.(current_user, params)
    respond
  end

  def submit
    @result = Vendors::Submit.(current_user, params)
    respond
  end

  def retract
    @result = Vendors::Retract.(current_user, params)
    respond
  end

  def reject
    @result = Vendors::Reject.(current_user, params)
    respond
  end

  def approve
    @result = Vendors::Approve.(current_user, params)
    respond
  end

  def deactivate
    @result = Vendors::Deactivate.(current_user, params)
    respond
  end

  def reactivate
    @result = Vendors::Reactivate.(current_user, params)
    respond
  end

  def take_control
    @result = Vendors::TakeControl.(current_user, params)
    respond
  end

  def return_control
    @result = Vendors::ReturnControl.(current_user, params)
    respond
  end

  def destroy
    @result = Vendors::Destroy.(current_user, params)
    respond
  end

  def bulk_reject
    @result = Vendors::BulkReject.(current_user, params)
    respond
  end

  def bulk_approve
    @result = Vendors::BulkApprove.(current_user, params)
    respond
  end

  def bulk_take_control
    @result = Vendors::BulkTakeControl.(current_user, params)
    respond
  end

  # Support

  def penny_test
    @result = Vendors::Support::PennyTest.(current_user, params)
    respond
  end

  def validate_gstin
    @result = Vendors::Support::ValidateGstin.(current_user, params)
    respond
  end

  def actions_config
    @result = ActionsManager::Processor.(current_user, params)
    respond
  end
end