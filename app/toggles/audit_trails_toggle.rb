class AuditTrailsToggle < ApplicationToggle

  def enabled?
    feature_flag 'permissions/audit_trails#enabled', false
  end

end