json.bulk_items do
	json.array! @result.parsed_data.each do |item|
		json.merge! item[:single_item].as_json
		# Overwrite these attributes to what was written in the excel sheet

		if item[:category_id].present?
			json.category_name item[:category_name]
			json.category_id item[:category_id]
		end

		json.rate item[:rate]
		json.tax item[:tax]
		json.discount item[:discount]

		json.quantity item[:quantity]
		json.comment item[:comment]

		json.department_id item[:department_id]
		json.department_name item[:department_name]

		json.cost_center_id item[:cost_center_id]
		json.cost_center_name item[:cost_center_name]
	end
end
