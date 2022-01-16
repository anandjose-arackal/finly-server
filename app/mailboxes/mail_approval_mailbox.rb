class MailApprovalMailbox < ApplicationMailbox
  error_logger = Logger.new("#{Rails.root}/log/mail_approval_errors.log")

  before_processing :ensure_user

  def process
    return if @user.nil?
    body = mail.decoded.split("\n")[0] #check approve
    comment =  mail.decoded.split("\n")[1] #check nil
    approval_mail_uid = mail.in_reply_to
    @result = Procurements::Invoices::Approve.(@user, params)
  end


  def ensure_user
    ActsAsTenant.without_tenant do
      @user = User.find_by(email: mail.from)
    end
    ActsAsTenant.current_tenant = @user.company
  end

end