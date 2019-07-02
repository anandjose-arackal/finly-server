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

		json.item_amount item[:item_amount]
        json.item_discount_amount item[:item_discount_amount]
        json.item_taxable_amount item[:item_taxable_amount]
        json.item_tax_amount item[:item_tax_amount]
        json.item_total_amount item[:item_total_amount]
	end
end

json.summary @result.summary
