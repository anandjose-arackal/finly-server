class VendorFormsController < BaseControllers::WebBase

  layout :resolve_layout

  def show
    endpoint Docs::P2P::Vendors::Ops::Show
  end

  def create
    endpoint Docs::P2P::Vendors::Ops::Create
  end

  def create_and_submit
    endpoint Docs::P2P::Vendors::Ops::CreateAndSubmit
  end

  def update
    endpoint Docs::P2P::Vendors::Ops::Update
  end

  def submit
    endpoint Docs::P2P::Vendors::Ops::Submit
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

  # def penny_test
  #   @result = Vendors::Support::PennyTest.(current_user, params)
  #   respond
  # end

  def penny_test
    # todo - I2P - uncomment in production
    # @result = Vendors::Support::PennyTest.(current_user, params)
    bank_account_master = BankAccountMaster.find_by(account_number: params[:bank_account][:account_number], ifsc: params[:bank_account][:ifsc])
    data = {
        bank_account_master: bank_account_master.as_json,
        card_id: params[:card_id],
        success: bank_account_master.present? ? true : false
    }
    respond_to do |format|
      format.json {render json: data.as_json}
    end
  end

  def validate_gstin
    @result = Vendors::Support::ValidateGstin.(current_user, params)
    respond
  end

  def actions_config
    @result = ActionsManager::Processor.(current_user, params)
    respond
  end

  def counts
    @result = Vendors::Counts.(current_user, params)
    respond
  end

  def export
    @result = Vendors::Exports::Generate.(current_user, params)
    respond
  end

  def resolve_layout
    if ["create", "update"].include?(action_name)
      'trailblazers'
    else
      'application'
    end
  end
end