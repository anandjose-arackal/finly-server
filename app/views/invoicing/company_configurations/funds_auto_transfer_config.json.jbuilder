json.extract! @result.auto_transfer_config, :frequency_name, :frequency_day, :amount_transfer_type, :enabled, :transfer_mode
json.threshold_amount @result.auto_transfer_config&.threshold_amount&.value