Rails.application.configure do
  cube_config = Rails.application.config_for(:cubejs) || {}
  config.cube_js = OpenStruct.new
  config.cube_js.api_key = cube_config[:api_key]
  config.cube_js.base_url = cube_config[:base_url]
end