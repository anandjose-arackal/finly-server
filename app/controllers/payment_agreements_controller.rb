class PaymentAgreementsController < BaseControllers::WebBase

  def index
    @result = PaymentAgreements::Index.(current_user, params)
    respond
  end

  def show
    @result = PaymentAgreements::Show.(current_user, params)
    respond
  end

  def create
    @result = PaymentAgreements::Create.(current_user, params)
    respond
  end

  def update
    @result = PaymentAgreements::Update.(current_user, params)
    respond
  end

  def destroy
    @result = PaymentAgreements::Destroy.(current_user, params)
    respond
  end

  def save_and_submit
    @result = PaymentAgreements::SaveAndSubmit.(current_user, params)
    respond
  end

  def submit
    @result = PaymentAgreements::Submit.(current_user, params)
    respond
  end

  def retract
    @result = PaymentAgreements::Retract.(current_user, params)
    respond
  end

  def reject
    @result = PaymentAgreements::Reject.(current_user, params)
    respond
  end

  def approve
    @result = PaymentAgreements::Approve.(current_user, params)
    respond
  end

  def unapprove
    @result = PaymentAgreements::Unapprove.(current_user, params)
    respond
  end

  def take_control
    @result = PaymentAgreements::TakeControl.(current_user, params)
    respond
  end

  def return_control
    @result = PaymentAgreements::ReturnControl.(current_user, params)
    respond
  end

  def edit_config
    @result = PaymentAgreements::EditConfig.(current_user, params)
    respond
  end

  def actions_configuration
    @result = ActionsManager::Processor.(current_user, params)
    respond
  end


  def count
    @result = PaymentAgreements::Count.(current_user, params)
    respond
  end

end