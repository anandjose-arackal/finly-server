json.bulk_items do
	json.array! @result.parsed_data.each do |item|
		json.merge! item[:single_item].as_json
		# Overwrite these attributes to what was written in the excel sheet
		json.unit_price item[:unit_price]

		json.quantity item[:quantity]
		json.purpose item[:purpose]
	end
end
