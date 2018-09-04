class AssociateInvoiceWithCompanyIdsRetrospectively < ActiveRecord::Migration
  def change
    Invoice.all.each do |invoice|
      company_id = invoice.payments.first&.company_id
      invoice.update(company_id: company_id)
    end
  end
end
