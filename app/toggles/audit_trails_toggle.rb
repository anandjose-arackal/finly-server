class AuditTrailsToggle < ApplicationToggle

  def templates_enabled?
    feature_flag 'release/audit_trails#templates_enabled', false
  end

end