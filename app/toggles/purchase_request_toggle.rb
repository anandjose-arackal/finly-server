class PurchaseRequestToggle < ApplicationToggle

  def enabled?
    feature_flag 'release/purchase_request#forms_enabled', false
  end

  def bulk_import_enabled?
    feature_flag 'release/purchase_request#bulk_import_enabled', false
  end
end