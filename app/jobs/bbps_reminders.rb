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
    ## Subscription joins below tables:
    # POCs - for email IDs
    # Department
    # Category
    #
    @logger.info "Running only for Dunzo in staging mode\n***\n"
    if @companies.include?(324) # Spot where you'd fix Flagging per company
      ActsAsTenant.current_tenant = Company.find 324
      bills = BbpsBill.where(due_date: Date.today-120...Date.today).includes(:subscription)
      bills.each do |bill|
        # name = bill.subscription.name
        # department = Department.find bill.department_id
        # amount = Amount.find bill.amount_id
        # cost_center = CostCenter.find bill.cost_center
        # location = Location.find bill.location_id
        @logger.info "Bill due: #{name} -- ; -- Sending email(s) to #{bill.subscription.pocs.collect(&:email)}"
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

#     Click here for more Details.

#     If you have already submitted your payment, please disregard this reminder.

#     Thanks,
#     Team Finly
