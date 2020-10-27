class AnalyticsDashboard::Resolver < Resolver::API

  entity AnalyticsDashboard

  def load(params)
    user_records = self.entity.where(created_by_id: user.id)
    user_records.or(self.entity.where(is_system_dashboard: true).where("id not in (#{user_records.where.not(system_dashboard_id: nil).select(:system_dashboard_id).to_sql})"))
  end

end