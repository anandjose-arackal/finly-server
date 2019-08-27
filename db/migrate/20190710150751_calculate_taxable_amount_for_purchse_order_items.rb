class CalculateTaxableAmountForPurchseOrderItems < ActiveRecord::Migration[5.2]
  def change
  	PurchaseOrderItem.all.each do |item|
		if item.taxable_amount.blank?
			item_quantity = (item.quantity || 0).to_f
		    item_rate = (item.rate || 0).to_f
		    item_discount = (item.discount || 0).to_f
		    item_amount = (item_quantity * item_rate)
		    item_taxable_amount = item_amount - item_discount
		    item.taxable_amount = Amount.new(value: item_taxable_amount, currency_id: 1)
		    item.save
		end
	end
  end
end
