class AnalyticsDashboard::Resolver < Resolver::API

  entity AnalyticsDashboard

  def load(params)
    user_records = self.entity.where(created_by_id: user.id)
    records = user_records.or(self.entity.where(is_system_dashboard: true).where("id not in (#{user_records.where.not(system_dashboard_id: nil).select(:system_dashboard_id).to_sql})"))
    ids = records.select do |record|
      record.feature_toggle.blank? or user.feature_toggle.enabled?(record.feature_toggle)
    end.pluck(:id)
    records.where(id: ids)
  end

end