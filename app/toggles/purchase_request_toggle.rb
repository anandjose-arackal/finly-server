class PurchaseRequestToggle < ApplicationToggle

  def enabled?
    feature_flag 'release/purchase_request#forms_enabled', false
  end

end