class AuditTrailsToggle < ApplicationToggle

  def enabled?
    feature_flag 'release/audit_trails#enabled', false
  end

end