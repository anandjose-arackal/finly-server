class AnalyticsDashboard::Contract < Reform::Form

  property :name, validates: {presence: true}
  property :description
  property :default
  property :app, deserializer: -> (input, represented, **) {
    represented.app ||= RequestStoreUtil.current_app
  }
  property :reports#, validates: {presence: true}

end