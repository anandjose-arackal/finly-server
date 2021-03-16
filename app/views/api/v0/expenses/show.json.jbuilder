json.partial! 'expense', expense: @result.expense
json.tax_rates @result.tax_rates.non_deleted
json.state_codes @result.gst_state_codes