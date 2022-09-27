class PurchaseOrderToggle < ApplicationToggle

  def enabled?
    feature_flag 'release/purchase_order#forms_enabled', false
  end

  def bulk_import_enabled?
    feature_flag 'release/purchase_order#bulk_import_enabled', false
  end
end