class VendorToggle < ApplicationToggle

  def forms_enabled?
    feature_flag 'release/forms_vendors#enabled', false
  end

end