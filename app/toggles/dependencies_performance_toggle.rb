class DependenciesPerformanceToggle < ApplicationToggle
  def enabled?
    feature_flag 'release/dependencies_json_performance_fix', false
  end
end