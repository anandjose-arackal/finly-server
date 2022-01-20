class MailApprovalMailbox < ApplicationMailbox
  error_logger = Logger.new("#{Rails.root}/log/mail_approval_errors.log")

  before_processing :ensure_user

  def process
    return if @user.nil?
    approval_uuid =  mail.recipients_addresses.to_sentence.to_s.split(".approval")[0]
    approval_uuid = approval_uuid.gsub('"','') #outlook has some extra quotes
    Rails.logger.info "Email::Approval::processing methods : #{mail.methods}"
    email_approval = EmailApproval.where(approval_uuid: approval_uuid)&.first
    if email_approval.nil?
      Rails.logger.info "Email approval not found for sentence::#{mail.recipients_addresses.to_sentence}"
      Rails.logger.info "Email approval not found for uuid::#{approval_uuid}"
      return false
    end
    body = mail.decode_body.split("\n")
    if body.nil?
      Rails.logger.info "Body is nil"
      return false
    end
    params = {id: email_approval.documentable_id}
    invoice = Invoice.find(email_approval.documentable_id)
    
    Rails.logger.info "Email::Approval::processing mail::decode::string : #{mail.decode_body.to_s}"
    Rails.logger.info "Email::Approval::processing mail::decode::inspect::approve : #{mail.decode_body.to_s.downcase.include?("approve")}"
    Rails.logger.info "Email::Approval::processing mail::decode::inspect::reject : #{mail.decode_body.to_s.downcase.include?("reject")}"
    
    Rails.logger.info "Email::Approval::processing can::approve #{can_approve(invoice)}"
    Rails.logger.info "Email::Approval::processing can::reject #{can_reject(invoice)}"
    if !invoice.processing?
      Rails.logger.info "Invoice is not in processing state"
      return false
    elsif mail.decode_body.to_s.downcase.include?("approve") && can_approve(invoice)
      @result = Procurements::Invoices::Approve.(@user, params)
      #email_approval.update(email_approval_status_id: EmailApprovalStatus.id_for(:approved))
    elsif mail.decode_body.to_s.downcase.include?("reject") && can_reject(invoice)
      params[:note] = "Invoice has been rejected via email by #{mail.from&.first} on #{Time.now.strftime("%Y-%d-%m %H:%M:%S %Z")}"
      @result = Procurements::Invoices::Reject.(@user, params)
      #email_approval.update(email_approval_status_id: EmailApprovalStatus.id_for(:rejected))
    end
    error_logger.error("Mailbox Item failed to create: #{item.errors.full_messages}") rescue nil
  end

  def can_approve(invoice)
    invoice.processing? && user_in_level?(invoice)
  end

  def can_reject(invoice)
    invoice.processing? && user_in_level?(invoice)
  end

  def user_in_level?(invoice)
    # level = invoice.level
    # amount = invoice.net_amount.value rescue 0
    # allowed = level.present? ? level.level_reviewer_mappings.with_threshold(amount).pluck(:reviewer_id).include?(user.id) : false
    provider_name = invoice.get_invoice_provider_name
    invoice.get_reviewers(nil, provider_name).include?(@user)
  end


  def ensure_user
    ActsAsTenant.without_tenant do
      @user = User.find_by(email: mail.from)
    end
    if @user.nil?
      return false
    end
    ActsAsTenant.current_tenant = @user.company
  end

end