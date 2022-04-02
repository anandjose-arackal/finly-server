class RemoveDuplicateSequence < BaseJob

  def self.perform_job
    puts " ----------------------------- PERFORMING #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"
    Rails.logger.level =0
    Company.all.each do |company|
      ActsAsTenant.current_tenant = Company.find(company.id)
      RequestStoreUtil.set_current_company Company.find(company.id)
      RequestStoreUtil.set_current_user(company.users.only_admins.first)
      dup_invoice_ids =Invoice.where.not(invoice_type_id:   InwardInvoiceType.id_for(:beneficiary)).where('created_at > ?', Date.parse('13-08-2021')).select(:company_id, :invoice_id).group(:invoice_id,:company_id).having('count(invoice_id) >1').pluck(:invoice_id)
      dup_invoice_ids.each do |invoice_id|
        invoice = Invoice.where(invoice_id: invoice_id).last
        invoice.invoice_id = nil
        invoice.save
      end

      dup_po_ids =PurchaseOrder.where('created_at > ?', Date.parse('01-12-2021')).select(:company_id, :po_number).group(:po_number,:company_id).having('count(po_number) >1').pluck(:po_number)
      dup_po_ids.each do |po_number|
        purchase_order = PurchaseOrder.where(po_number:  po_number).last
        purchase_order.po_number= nil
        purchase_order.save
      end
    end
  end
end