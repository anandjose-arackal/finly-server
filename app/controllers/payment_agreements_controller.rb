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

  def document_config
    @result = PaymentAgreements::DocumentConfig.(current_user, params)
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

  def policy_config
    @result = PaymentAgreements::PolicyConfig.(current_user, params)
    respond
  end

  def filter_config
    @result = PaymentAgreements::FilterConfig.(current_user, params)
    respond
  end

  def summary
    # @result = PaymentAgreements::Summary.(current_user, params)
    # respond
    @result = PaymentAgreements::Show.(current_user, params)
    respond
  end

  # Invoices for each agreement
  def upcoming_invoices
    @result = PaymentAgreements::UpcomingInvoices.(current_user, params)
    respond
  end

  # Invocies for all agreements
  def all_upcoming_invoices
    @result = PaymentAgreements::AllUpcomingInvoices.(current_user, params)
    respond
  end  

  def attachments
    @result = PaymentAgreements::Attachments.(current_user, params)
    respond
  end

  def invoice_history
    @result = PaymentAgreements::InvoiceHistory.(current_user, params)
    respond
  end

  # Manually terminate agreement
  def terminate
    @result = PaymentAgreements::Terminate.(current_user, params)
    respond
  end

  def revise
    @result = PaymentAgreements::Revise.(current_user, params)
    respond
  end


  # Used for revised agreements
  def editable_fields
    @result = PaymentAgreements::EditableFields.(current_user, params)
    respond
  end

end