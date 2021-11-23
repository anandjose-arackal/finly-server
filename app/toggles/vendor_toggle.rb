class VendorToggle < ApplicationToggle

  def forms_enabled?
    feature_flag 'release/vendors#forms_enabled', false
  end

  def bulk_import_enabled?
    feature_flag 'release/vendors#bulk_import_enabled', false
  end

end