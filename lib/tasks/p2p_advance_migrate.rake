desc "Migrate advances from old system to P2P"

task :migrate_advances, [:company_id] do |t, args|
  result = []
  company = Company.find args[:company_id].to_i

  ActsAsTenant.with_tenant(company) do
    documents = PurchaseOrder.where(company_id: company.id)
    documents.find_in_batches(batch_size: 1000) do |batch|
      batch.each do |document|
				document.po_advance_base_amount = document.advance_amount&.value&.to_f
				document.po_advance_tds_percent = document.advance_tds_slab&.tds
				document.items.each do |item|
					item.po_item_tds_amount = (item.taxable_amount&.value&.to_f * document.po_advance_tds_percent)/100 rescue 0
					item.save
				end
				document.po_total_tds_amount 		= document.items.where(tds_applicable: true).map(&:po_item_tds_amount).sum
				document.po_advance_tds_amount  = [document.po_total_tds_amount, document.po_advance_base_amount].min # maybe the percentage yet to be calculated
				document.po_advance_payable     = document.po_advance_base_amount - document.po_total_tds_amount
      end
    end

		invoices = Invoice.where(invoice_type_id: InwardInvoiceType.id_for(:tax_invoice)).where(company_id: company.id)

		invoices.find_in_batches(batch_size: 1000) do |batch|
			batch.each do |inv|
				inv.items.each do |item|
					item.item_tds_percent = inv.procurement.purchase_prder&.po_advance_tds_percent
					item.item_tds_amount = (item.taxable_amount&.value&.to_f * item.item_tds_percent)/100 rescue 0
					item.save
				end

				inv.invoice_tds_amount = inv.items.where(tds_applicable: true).map(&:po_item_tds_amount).sum
				inv.adjusted_po_advance_payable_amount = inv.po_adjusted_advance
				
			end
		end
  end
end