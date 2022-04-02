class PurchaseOrderToggle < ApplicationToggle

  def enabled?
    feature_flag 'release/purchase_order#forms_enabled', false
  end

end