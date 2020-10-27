class AnalyticsDashboard::Contract < Reform::Form

  property :name, validates: {presence: true}
  property :description
  property :default
  property :app, validates: {presence: true}
  property :reports, validates: {presence: true}

end