class SeedInvoiceItemsWithDepartmentAndCostCenter < ActiveRecord::Migration[5.2]
  def change
    Invoice.where(invoice_type_id: InwardInvoiceType.ids_for(:tax_invoice, :non_po_invoice)).each do |invoice|
      department = invoice.department
      cost_center = invoice.cost_center
      invoice.items.update_all(department_id: department&.id, cost_center_id: cost_center&.id)
    end
  end
end
