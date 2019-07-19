class CalculateTaxableAmountForInvoiceLineItems < ActiveRecord::Migration[5.2]
  def change
    InvoiceLineItem.all.each do |item|
		item_quantity = (item.quantity || 0).to_f
	    item_rate = (item.rate || 0).to_f
	    item_discount = (item.discount || 0).to_f
	    item_amount = (item_quantity * item_rate)
	    item_taxable_amount = item_amount - item_discount
	    if item.taxable_amount.present?
	        item.taxable_amount.value = item_taxable_amount
	    else
	        item.taxable_amount = Amount.new(value: item_taxable_amount, currency_id: 1)
	    end
	    item.save
		end
  end
end
