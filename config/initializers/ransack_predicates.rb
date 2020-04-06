Ransack.configure do |config|
  config.sanitize_custom_scope_booleans = false
  Filters::Predicates.setup(config)
end