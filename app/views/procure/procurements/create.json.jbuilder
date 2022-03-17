json.merge! @result.procurement.as_json
json.forms_enabled  PurchaseOrderToggle.new(RequestStoreUtil.current_user).enabled?