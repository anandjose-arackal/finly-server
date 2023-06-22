require 'pp'

class BbpsReminders < BaseJob
  def self.perform_job
    @logger = Logger.new "#{Rails.root}/log/reminders.log"
    @logger.info "Job run started at #{Time.now}"
    get_count_of_customers
    get_list_of_bills
  end

  private
  def self.get_count_of_customers
    counts = ActsAsTenant.without_tenant do BbpsBill.where(due_date: Date.today-120...Date.today).group(:company_id).count end
    @companies = counts.keys
    @logger.debug "Count of bills Beautified: \n============================="
    @logger.debug pp counts
    @logger.debug "\n============================="
  end

  def self.get_list_of_bills
    @logger.info "Running only for Dunzo in staging mode\n***\n"
    if @companies.include?(324) # Spot where you'd fix Flagging per company
      ActsAsTenant.current_tenant = Company.find 324
      bills = BbpsBill.joins(:department, :category, :cost_center, :location, :amount)
                      .select(" `bbps_bills`.*
                      `departments`.`name` AS department,
                      `categories`.`name` AS category,
                      `cost_centers`.`name` AS cost_center,
                      `branch_locations`.`name` AS location,
                      `amounts`.`value` AS amount")
                      .where(due_date: Date.today-120...Date.today).includes(subscription: :pocs)
      bills.each do |bill|
        @payload = {}
        @payload[:biller_name] = bill.subscription.name
        @payload[:due_date] = bill.due_date
        @payload[:department] = bill[:department]
        @payload[:category] = bill[:category]
        @params[:amount] = bill[:amount]
        @payload[:cost_center] = bill[:cost_center]
        @payload[:location] = bill[:location]
        @payload[:amount] = bill[:amount]
        @payload[:to] = bill.subscription.pocs.collect(&:email)
        @logger.info "Bill due: #{@payload[:biller_name]} -- ; -- Sending email(s) to #{@payload[:to]} -- ; -- Location: #{@payload[:location]}"

      end
    end
    @logger.info "\n***\n"
  end
end

# ==begin
#     To : Point of contact
#     Subject : Reminder - Payment for [Utility] Bill Due
#
#   Dear Sir/Mam,
#     This is a reminder that the payment for your [Utility title] bill due on [Due Date].
#     Below are the additional Details of the bill.
#
#     Bill type : (Electricity/telephone Etc)
#     Operator/Vendor : (Operator/Vendor Name)
#     Bill amount : (Bill Amount as per invoice)
#     Invoice No: (Invoice No as per invoice)
#     Department : (Department Name)
#     Cost Center : (Cost Center Name)
#     Location: (Location Name)
#
#     Click here for more Details.
#
#     If you have already submitted your payment, please disregard this reminder.
#
#     Thanks,
#     Team Finly
