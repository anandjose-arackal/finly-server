class UnapprovedTransactionReminders < BaseJob
  def self.perform_job
    @logger = Logger.new "#{Rails.root}/log/reminders.log"
    # @logger.info "#{self.name} => Job run started at #{Time.now}"
    
    # to store whether a company has enabled to send the reminders
    @reminders_enabled = Hash.new
    
    find_awaiting_users_with_counts
    extract_users
    
    if @users.present?
      trigger_mailer_event
    else
      @logger.info "#{self.name} => No users found for any pending actions at #{Time.now}"
    end
    
    # @logger.info "#{self.name} => Job run ended at #{Time.now}"
  end

  private

  def self.check_if_reminders_enabled(user)
    return if user.blank?

    return @reminders_enabled[user.company_id] if @reminders_enabled[user.company_id].present?

    first_user = user.company.users.first # fetch the first user of the company
    status = UnapprovedTransactionRemindersToggle.new(first_user).enabled?
    @reminders_enabled[user.company_id] = status ? "send" : "not send"
  end

  def self.extract_users
    @users ||= User.includes(:company)
                .where(id: @awaiting_users_with_count.keys)
                .select(:id, :email, :first_name, :last_name, :company_id)
  end

  def self.find_awaiting_users_with_counts
    @awaiting_users_with_count = Hash.new

    models.each do |model, path|
      current_records = model.awaiting_records_without_users

      current_records.each do |user_id, count|
        @awaiting_users_with_count[user_id] = Hash.new if @awaiting_users_with_count[user_id].blank?
        @awaiting_users_with_count[user_id].merge!(path => count)
      end
    end
  end

  def self.models
    # extracted [:model] and [:path] manually from Dashboard::P2P::AwaitingApproval::TILES
    # but not calling the module directly because any change in that code might break this job because of
    # unavailibility of 'dlrm_with_level' associations for newly added 'TILE' i.e. TILES[0][:model]
    [
      [PurchaseRequest, "purchase_requests"],
      [PurchaseOrder, "purchase_orders"],
      [Invoice, "invoices"],
      [BbpsBill, "utility_bills"],
      [BankPaymentRequest, "payment_tickets"],
      [YesBankVendor, "vendors"],
      [PaymentAgreement, "agreements"],
      [BbpsBillerSubscription, "utility_subscriptions"]
    ]
  end

  def self.trigger_mailer_event
    @users.each do |user|
      if user.email.present? && check_if_reminders_enabled(user) == "send"
        params = @awaiting_users_with_count[user.id]
        Event::EReminders::UnapprovedTransaction.(user, params)
      end
    end
  end
end

=begin
  To - Approvers Email ID

  Subject : Unapproved Transaction requires your attention

  Dear [Approver Name],
  Following transactions are waiting for your approval. Request you to Please check and do the needful. Click Here to login

  Purchase Request : [No of purchase Request]
  Purchase Order: [No of Purchase order]
  Invoices: [No of Invoices]  ( All type of invoices I2P, P2P, ABP, Utility Etc]
  Payment tickets [No of payment tickets]
  Vendors [No of vendors]
  Utility Subscription [ No of utility subscription]
  Agreement Master [ No of agreement]

  Kindly ignore the email if the same is already approved. 

  Thanks,

  Team Finly
=end
