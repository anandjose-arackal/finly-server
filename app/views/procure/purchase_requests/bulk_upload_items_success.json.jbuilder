json.bulk_items do
	json.array! @result.parsed_data.each do |item|
		# json.merge! item[:single_item].as_json
		# Overwrite these attributes to what was written in the excel sheet
		json.attachment_attributes nil
		json.estimated_cost do
			json.currency_id nil
			json.value nil
			json.id nil
		end

		json.unit_cost do
			json.value item[:unit_price]
			json.currency_id 1
			json.id nil
		end
		json.unit_of_measurement item[:unit_of_measurement]
		json.quantity item[:quantity]
		json.purpose item[:purpose]
		json.required_by_date item[:required_by_date]

		json.delivery_location do
			json.name item[:delivery_location_name]
			json.id item[:delivery_location]
		end
		json.preferred_vendor do
			json.vendor_name item[:preferred_vendor]
			json.vendor_id nil
		end

		json.preferred_vendors []
		json.rejected nil
		json.status nil

		json.product_details do
			json.product_name item[:single_item].description
			json.id item[:single_item].id
		end
	end
end
