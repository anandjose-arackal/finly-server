class MailApprovalMailbox < ApplicationMailbox
  before_processing :ensure_user

  def process
    return if @user.nil?

    log_email_content
    return if no_email_approval_found? && log_no_email_approval_found
    return if no_email_body? && log_no_email_body

    error_logger.info "\n\t\t\t*******\n document type #{document_type} \n\n\t\t********"

    if document_type == PurchaseRequest
      Email::PrApprovalService.new(@user, document, mail.from, email_body, error_logger).process
    elsif document_type == PurchaseOrder
      Email::PoApprovalService.new(@user, document, mail.from, email_body, error_logger).process
    else
      return if no_invoice? && log_no_invoice
      return if invoice_not_in_processing? && log_invoice_not_in_processing

      # return if non_po_invoice_disabled? && log_non_po_invoice_disabled

      aprove_or_reject
    end
  end

  def aprove_or_reject
    error_logger.info "\n\t\t\t*******\n Reached Approve oR Reject \n\n\t\t********"
    if email_body.downcase.include?('approve') && can_approve
      approve
    elsif email_body.downcase.include?('reject') && can_reject
      reject
    else
      error_logger.info "\n\t\t\t*******\n no approve or reject #{can_reject} \n\n\t\t********"
      error_logger.info "\n\t\t\t*******\n no approve or reject #{user_in_level?} \n\n\t\t********"
    end
  end

  def approve
    @result = Procurements::Invoices::Approve.(@user, params)
    document = @result.params['document']

    if @result.success? && !document.processing?
      EmailApproval.delete_email_approval(document.id)
    else
      @error_logger.error("Invoice #{document.id} failed to approve by #{mail.from} because #{@result.inspect}")
    end
  end

  def document_type
    @document_type ||= document.class
  end

  def document
    @document ||= email_approval.documentable
  end

  def params
    { id: email_approval.documentable_id }
  end

  def reject
    reject_params = params

    error_logger.info "\n\t\t\t*******\n Reached Reject \n\n\t\t********"
    reject_params[:note] = "Invoice has been rejected via email by #{mail.from&.first} on #{Time.now.strftime('%Y-%d-%m %H:%M:%S %Z')}"
    error_logger.info "\n\t\t\t*******\n Params: #{reject_params} \n\n\t\t********"


    @result = Procurements::Invoices::Reject.(@user, reject_params)
    document = @result.params['document']

    error_logger.info "\n\t\t\t*******\n Success: #{@result.success?} \n\n\t\t********"
    error_logger.info "\n\t\t\t*******\n Par: #{reject_params} \n\n\t\t********"
    error_logger.info "\n\t\t\t*******\n Document id: #{document.inspect} \n\n\t\t********"
    error_logger.info "\n\t\t\t*******\n Success: #{document.messages} \n\n\t\t********"
    error_logger.info "\n\t\t\t*******\n Document id: #{document.id} \n\n\t\t********"
    error_logger.info "\n\t\t\t*******\n Document id: #{document.rejected?} \n\n\t\t********"

    if @result.success? && !document.processing?
      error_logger.info "\n\t\t\t*******\n deleting mail approvals \n\n\t\t********"
      EmailApproval.delete_email_approval(document.id)
    else
      @error_logger.error("Invoice #{document.id} failed to reject by #{mail.from} because #{@result.inspect}")
    end
  end

  def log_info(content)
    error_logger.info content
  end

  def error_logger
    @error_logger ||= Logger.new(Constants::EMAIL_APPROVAL_ERROR_PATH)
  end

  def log_email_content
    error_logger.info "\n\t\t\t*******\nEmail Content\n#{email_body}\n\n\t\t********"
  end

  def approval_uuid
    return @approval_uuid if @approval_uuid

    recipient = mail.recipients_addresses.to_sentence.to_s
    @approval_uuid = Rails.env.production? ? recipient.split('@approval')[0] : recipient.split('@dev.approval')[0]
    @approval_uuid.gsub!('"', '') # outlook has some extra quotes
    @approval_uuid
  end

  def email_body
    body = mail.text_part&.decode_body.to_s
    return body if body.present?

    mail.decoded
  end

  def email_approval
    @email_approval ||= EmailApproval.where(approval_uuid: approval_uuid)&.first
  end

  def no_email_approval_found?
    email_approval.nil?
  end

  def log_no_email_approval_found
    # User might belong to multiple entities, and if document is from one of those other entities
    unless ensure_document_id_matches_user
      error_logger.error("Email approval not found for approval::uuid #{approval_uuid} under the company #{@user.company_id}")
    else
      error_logger.error("** approval::uuid #{approval_uuid} not found even after Multiple entities search")
    end

    true
  end

  def no_email_body?
    email_body.split("\n").nil?
  end

  def log_no_email_body
    error_logger.info("body not found for approval::uuid #{approval_uuid}")

    true
  end

  def no_invoice?
    invoice.blank?
  end

  def log_no_invoice
    error_logger.error("Invoice not found for approval::uuid #{approval_uuid} under
                        user: #{@user.email} ; company_id: #{@user.company_id}")

    true
  end

  def invoice_not_in_processing?
    !invoice.processing?
  end

  def log_invoice_not_in_processing
    @error_logger.error("Invoice #{invoice.id} failed because it is in #{invoice.status.name}, not in processing state")

    true
  end

  def non_po_invoice_disabled?
    !NonPoInvoiceToggle.new(@user).enabled?
  end

  def log_non_po_invoice_disabled
    @error_logger.error("Invoice #{invoice.id} failed because NonPoInvoice toggle is not enabled")
    delete_email_approvals

    true
  end

  def invoice
    @invoice ||= Invoice.find_by_id(email_approval.documentable_id)
  end

  def delete_email_approvals
    EmailApproval.delete_email_approval(invoice.id)
  end

  def can_approve
    invoice.processing? && user_in_level?
  end

  def can_reject
    invoice.processing? && user_in_level?
  end

  def user_in_level?
    # level = invoice.level
    # amount = invoice.net_amount.value rescue 0
    # allowed = level.present? ? level.level_reviewer_mappings.with_threshold(amount).pluck(:reviewer_id).include?(user.id) : false
    provider_name = invoice.get_invoice_provider_name
    invoice.get_reviewers(nil, provider_name).include?(@user)
  end

  def ensure_user
    return if no_email_approval_found? && log_no_email_approval_found
    error_logger.info "\n\t\t\t*******\n Mail from \n#{mail.from}\n\n\t\t********"

    @user = ActsAsTenant.without_tenant { User.find_by(email: mail.from, company_id: email_approval.company_id) }
    return false if @user.nil?

    set_current_tenant @user.company
  end

  def set_current_tenant(company)
    ActsAsTenant.current_tenant = company
  end

  def run_without_tenant(&block)
    ActsAsTenant.without_tenant(&block)
  end

  def ensure_document_id_matches_user
    ### Basically ensure Document's Company ID matches with the Company ID of the email sender ###
    email_approval = run_without_tenant { EmailApproval.where(approval_uuid: approval_uuid)&.first }
    user_company_ids = run_without_tenant { User.where(email: mail.from).pluck(:company_id) }

    if user_company_ids.include? email_approval.company_id
      set_current_tenant(Company.find(email_approval.company_id))
      @user = User.find_by(email: mail.from)
      return true unless @user.nil?

      set_current_tenant(nil)
      false
    end
  end
end
