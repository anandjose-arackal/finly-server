# this operation will update details like scheduled on, description, bank transfer type etc.
# about the payment order, which is independent of the payment items

class BankTransfer::PaymentRequest::Update::UpdateSummary < BankTransfer::PaymentRequest::Update::Base

  attr_accessor :payment_order_params, :payment_request_params

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
      return
    end
    if params[:bank_payment_request].blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    super
    self.payment_order_params = order_params
    self.payment_request_params = request_params
  end

  def validate
    return if record_not_present
    # Validate if user has access to show page    
    validate_document_access
    # Validate if user has access to payment ticket
    validate_association
  end

  def process
    unless payment_order.update(order_params)
      add_message :error, payment_order.errors.full_messages
      return
    end
    if payment_request.update(request_params)
      if BankPaymentRequest.status_ids(:open, :retracted, :rejected).include?(payment_request.status_id) && payment_request.owner_id == user.id
        # Create Document Level Reviewer Mapping
        # For setting level specific reviewers from reviewal chain for a document
        params[:reviewal_document] = self.payment_request.reload

        document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, params)
        unless document_reviewer_mappings_op.success?
          add_message :error, document_reviewer_mappings_op.messages[:error]
          return
        end
      end
    else
      add_message :error, payment_request.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Successfully updated summary"
  end

  private

  def order_params
    p = {}
    p = params.require(:bank_payment_request).permit(:scheduled_at)
    p[:payments_attributes] = []
    if params[:bank_payment_request][:bank_transfer_type].present?
      payment_order.payments.each do |payment|
        p[:payments_attributes] << {
            id: payment.id,
            payment_mode: params[:bank_payment_request][:bank_transfer_type]
        }
      end
    end
    p[:payment_mode] = params[:bank_payment_request][:bank_transfer_type]
    p.permit!
  end

  def request_params
    params.require(:bank_payment_request).permit(:description, :policy_id, :name)
  end

  def validate_presence
    if self.payment_request.blank? || (self.payment_request.company_id != user.company_id)
      add_message :error, "Payment ticket not found!"
      return false
    end
    true
  end

  def record_not_present
    !validate_presence
  end

  def validate_document_access
    BankTransfer::PaymentRequest::Index.(user, params).success?
  end


  def validate_association
    return if payment_request.update_if_owner(user) if BankPaymentRequestStatus.status_ids_for_owner.include?(payment_request.status_id)
    return if payment_request.update_if_admin(user) if !BankPaymentRequestStatus.status_ids_for_owner.include?(payment_request.status_id) || payment_request.owner_id.blank?
    return if payment_request.update_if_reviewer(user) if BankPaymentRequestStatus.status_ids_for_reviewer.include?(payment_request.status_id)
    return if payment_request.status_id
    add_message :error, 'Unable to update'
  end

end
