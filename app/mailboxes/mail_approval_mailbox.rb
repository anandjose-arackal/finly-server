class MailApprovalMailbox < ApplicationMailbox


  before_processing :ensure_user

  def process
    return if @user.nil?
    @error_logger = Logger.new("#{Rails.root}/log/mail_approval_errors.log")
    @error_logger.info "----------------------------"
    @error_logger.info "------------- Mail.body ---------------"
    @error_logger.info mail.body
    @error_logger.info "------------- Mail.body.split ---------------"
    @error_logger.info mail.decode_body.split("\n")
    @error_logger.info "----------------------------"
    approval_uuid =  Rails.env.production?? mail.recipients_addresses.to_sentence.to_s.split("@approval")[0] : mail.recipients_addresses.to_sentence.to_s.split("@dev.approval")[0]
    approval_uuid = approval_uuid.gsub('"','') #outlook has some extra quotes
    email_approval = EmailApproval.where(approval_uuid: approval_uuid)&.first
    if email_approval.nil?
      # User might belong to multiple entities, and if document is from one of those other entities
      unless ensure_document_id_matches_user(approval_uuid)
        @error_logger.info("Email approval not found for approval::uuid #{approval_uuid} under the company #{@user.company_id}")
        return false
      else
        email_approval = EmailApproval.where(approval_uuid: approval_uuid)&.first
        @error_logger.info "Done with Email loookup"
        if email_approval.nil?
          @error_logger.error("** approval::uuid #{approval_uuid} not found even after Multiple entities search")
          return false
        end
      end
    end
    @error_logger.info "------------ Final Object -----------------"
    @error_logger.info "Email Approval Object: #{email_approval}"
    @error_logger.info "-----------------------------"
    body = mail.decode_body.split("\n")
    if body.nil?
      @error_logger.info("body not found for approval::uuid #{approval_uuid}")
      return false
    end
    params = {id: email_approval.documentable_id}
    invoice = Invoice.find_by_id(email_approval.documentable_id)
    if invoice.nil?
      @error_logger.info("Invoice not found for approval::uuid #{approval_uuid}")
      return false
    end
    if !invoice.processing?
      @error_logger.info("Invoice #{invoice.id} failed because it is in #{invoice.status.name} not in processing state")
      return false
    elsif !NonPoInvoiceToggle.new(@user).enabled?
      @error_logger.info("Invoice #{invoice.id} failed because NonPoInvoice toggle is not enabled")
      EmailApproval.delete_email_approval(invoice.id)
      return false
    elsif mail.decode_body.to_s.downcase.include?("approve") && can_approve(invoice)
      @result = Procurements::Invoices::Approve.(@user, params)
      if @result.success? && !@result.params["document"].processing?
        EmailApproval.delete_email_approval(@result.params["document"].id)
      else
        @error_logger.error("Invoice #{@result.params["document"].id} failed to approve by #{mail.from} because #{@result.inspect}")
      end
    elsif mail.decode_body.to_s.downcase.include?("reject") && can_reject(invoice)
      params[:note] = "Invoice has been rejected via email by #{mail.from&.first} on #{Time.now.strftime("%Y-%d-%m %H:%M:%S %Z")}"
      @result = Procurements::Invoices::Reject.(@user, params)
      if @result.success? && !@result.params["document"].processing?
        EmailApproval.delete_email_approval(@result.params["document"].id)
      else
        @error_logger.error("Invoice #{@result.params["document"].id} failed to reject by #{mail.from} because #{@result.inspect}")
      end
    end
    
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

  def ensure_document_id_matches_user(approval_uuid)
    ### Basically ensure Document's Company ID matches with the Company ID of the email sender ###
    email_approval = ActsAsTenant.without_tenant do EmailApproval.where(approval_uuid: approval_uuid)&.first end
    user_company_ids = ActsAsTenant.without_tenant do User.where(email: mail.from).pluck(:company_id) end
    @error_logger.info "-----------------------------"
    @error_logger.info "Approval UUID: #{approval_uuid}"
    @error_logger.info "User Company IDs: #{user_company_ids}"
    @error_logger.info "Email Approval Object: #{email_approval.inspect}"
    @error_logger.info "-----------------------------"
    if user_company_ids.include? email_approval.company_id
      ActsAsTenant.current_tenant = Company.find(email_approval.company_id)
      @user = User.find_by(email: mail.from)
      @error_logger.info "------------ User -----------------"
      @error_logger.info "User: #{@user.email}"
      @error_logger.info "-----------------------------"
      return true unless @user.nil?
      ActsAsTenant.current_tenant = nil
      return false
    end
  end

end