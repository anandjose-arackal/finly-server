class AnalyticsDashboard::Contracts::Record < Reform::Form

  property :name, validates: {presence: true}
  property :description
  property :default
  property :app, deserializer: -> (input, represented, **) {
    represented.app ||= RequestStoreUtil.current_app
  }
  property :reports#, validates: {presence: true}
  collection :schedules, populate_if_empty: AnalyticsDashboardSchedule, form: AnalyticsDashboard::Contracts::Schedule
  collection :schedule_user_mappings, populate_if_empty: AnalyticsDashboardScheduleUserMapping do
    property :company_id, deserializer: -> (input, represented, **) do
      represented.company_id = represented.contract_root.model.company_id
    end
    property :user_id, validates: {presence: true}
  end

  # Ensure there is only one dashboard which has the default flag
  after_save do
    if default and model.id.present?
      model.created_by.analytics_dashboards
          .where(app: model.app)
          .where.not(id: model.id)
          .update_all(default: false)
    end
  end

end