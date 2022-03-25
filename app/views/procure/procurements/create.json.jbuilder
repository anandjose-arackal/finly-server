json.merge! @result.procurement.as_json
json.forms_enabled  @result.procurement&.purchase_order&.forms_flag_enabled || false