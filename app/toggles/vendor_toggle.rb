class VendorToggle < ApplicationToggle

  def forms_enabled?
    feature_flag 'release/vendors#forms_enabled', false
  end

end