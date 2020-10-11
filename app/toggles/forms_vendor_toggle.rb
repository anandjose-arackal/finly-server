class FormsVendorToggle < ApplicationToggle

  def enabled?
    feature_flag 'release/forms_vendors#enabled', false
  end

end