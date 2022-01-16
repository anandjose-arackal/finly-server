class MailApprovalMailbox < ApplicationMailbox
  error_logger = Logger.new("#{Rails.root}/log/mail_approval_errors.log")

  before_processing :ensure_user

  def process
    return if @user.nil?
    approval_uuid =  mail.recipients_addresses.to_sentence.split(".approval")[0]
    email_approval = EmailApproval.where(approval_uuid: approval_uuid)&.first
    if email_approval.nil?
      Rails.logger.info "Email approval not found"
      return false
    end
    body = mail.decode_body.split("\n")
    if body.nil?
      Rails.logger.info "Body is nil"
      return false
    end
    params = {id: email_approval.documentable_id}
    if email_approval.status.name != "pending"
      Rails.logger.info "Email approval is not in pending state"
      return false
    elsif body[0].downcase == "approve" && email_approval.status.name == "pending"
      @result = Procurements::Invoices::Approve.(@user, params)
      email_approval.update(email_approval_status_id: EmailApprovalStatus.id_for(:approved))
    elsif body[0].downcase == "reject" && email_approval.status.name == "pending"
      @result = Procurements::Invoices::Reject.(@user, params)
      email_approval.update(email_approval_status_id: EmailApprovalStatus.id_for(:rejected))
    end
  end


  def ensure_user
    ActsAsTenant.without_tenant do
      @user = User.find_by(email: mail.from)
    end
    ActsAsTenant.current_tenant = @user.company
  end

end