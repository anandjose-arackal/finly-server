json.bulk_items do
	json.array! @result.parsed_data.each do |item|
		json.merge! item[:single_item].as_json
		# Overwrite these attributes to what was written in the excel sheet

		if item[:category_id].present?
			json.category_name item[:category_name]
			json.category_id item[:category_id]
		end

		json.rate item[:rate]
		json.tax_rate_id item[:tax_rate_id]
		json.discount item[:discount]

		json.quantity item[:quantity]
		json.comment item[:comment]

		json.department_id item[:department_id]
		json.department_name item[:department_name]

		json.cost_center_id item[:cost_center_id]
		json.cost_center_name item[:cost_center_name]

		json.item_amount sprintf '%.2f', item[:item_amount]
        json.item_discount_amount sprintf '%.2f', item[:item_discount_amount]
        json.item_taxable_amount sprintf '%.2f', item[:item_taxable_amount]
        json.item_tax_amount sprintf '%.2f', item[:item_tax_amount]
        json.item_total_amount sprintf '%.2f', item[:item_total_amount]
        json.item_tax_split_igst sprintf '%.2f', item[:item_tax_split_igst]
        json.item_tax_split_cgst sprintf '%.2f', item[:item_tax_split_cgst]
        json.item_tax_split_sgst sprintf '%.2f', item[:item_tax_split_sgst]
	end
end

json.summary do
	json.sum_of_item_amount sprintf '%.2f', @result.summary[:sum_of_item_amount]
    json.sum_of_item_discount_amount sprintf '%.2f', @result.summary[:sum_of_item_discount_amount]
    json.sum_of_item_taxable_amount sprintf '%.2f', @result.summary[:sum_of_item_taxable_amount]
    json.sum_of_item_tax_amount sprintf '%.2f', @result.summary[:sum_of_item_tax_amount]
    json.sum_of_item_total_amount sprintf '%.2f', @result.summary[:sum_of_item_total_amount]
    json.sum_of_item_tax_split_igst sprintf '%.2f', @result.summary[:sum_of_item_tax_split_igst]
    json.sum_of_item_tax_split_cgst sprintf '%.2f', @result.summary[:sum_of_item_tax_split_cgst]
    json.sum_of_item_tax_split_sgst sprintf '%.2f', @result.summary[:sum_of_item_tax_split_sgst]
end