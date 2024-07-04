class PwInvoiceFixer < BaseJob
  def self.perform_job
    ActsAsTenant.current_tenant = Company.find(358)
    user = User.only_admins.first
    RequestStoreUtil.set_current_user user
    invoice_list = Invoice.where(invoice_status_id: [1,12]).or(Invoice.where("invoice_status_id = 7 AND due_date < #{Date.current}"))
    invoice_list.each do |invoice|
      invoice.update_invoice_status
    end
  end
end