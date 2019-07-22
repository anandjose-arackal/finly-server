class CalculateBillableAmountForTaxInvoiceItems < ActiveRecord::Migration[5.2]
  def change
 #  	Invoice.where(invoice_type_id: InwardInvocieType.id_for(:tax_invoice)).each do |invoice|
	# 	invoice.invoice_items.each do |item|
	# 	    if item.billable_amount.present? && item.billable_amount&.value.to_f <= 0
	# 	        item.billable_amount.value = item.taxable_amount&.value
	# 	    else
	# 	        item.billable_amount = Amount.new(value: item.taxable_amount&.value, currency_id: 1)
	# 	    end
	# 	    item.save
	# 	end
	# end
  end
end
