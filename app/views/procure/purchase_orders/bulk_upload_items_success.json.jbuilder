json.bulk_items do
	json.array! @result.parsed_data.each do |item|
		json.merge! item[:single_item].as_json
		# Overwrite these attributes to what was written in the excel sheet
		json.rate item[:rate]
		json.tax item[:tax]
		json.discount item[:discount]

		json.quantity item[:quantity]
		json.comment item[:comment]
	end
end
