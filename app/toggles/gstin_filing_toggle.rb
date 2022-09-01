class GstinFilingToggle < ApplicationToggle

  def enabled?
    feature_flag 'permissions/vendors/gstin_filing_enabled', false
  end

end