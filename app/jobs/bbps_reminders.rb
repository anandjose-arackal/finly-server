require 'pp'

class BbpsReminders < BaseJob
  def self.perform_job
    @logger = Logger.new "#{Rails.root}/log/reminders.log"
    @logger.info "Job run started at #{Time.now}"
    get_count_of_customers
    get_list_of_bills
  end

  private
  def get_count_of_customers
    counts = ActsAsTenant.without_tenant do BbpsBill.where(due_date: Date.today-120...Date.today).group(:company_id).count end
    @companies = counts.keys
    @logger.debug "Count of bills Beautified: \n============================="
    @logget.debug pp counts
    @logger.debug "\n============================="
  end

  def get_list_of_bills
    @logger.info "Running only for Dunzo in staging mode\n***\n"
    if @companies.include?(248) # Spot where you'd fix Flagging per company
      ActsAsTenant.current_tenant = Company.find 248
      bills = BbpsBill.where(due_date: Date.today-120...Date.today).includes(:subscription)
      bills.each do |bill|
        @logger.info "Bill due: #{bill.subscription.name} -- ; -- Sending email(s) to #{bill.subscription.pocs.collect(&:email)}"
      end
    end
    @logger.info "\n***\n"
  end
end