class AuditTrailsToggle < ApplicationToggle

  def audit_trails_enabled?
    feature_flag 'release/audit_trails#enabled', false
  end

end