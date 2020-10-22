Rails.application.configure do
  config.cube_js_api_key = Rails.application.config_for(:cubejs)[:api_key]
end