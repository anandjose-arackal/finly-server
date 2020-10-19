Rails.application.configure do
  searchkick_config = Rails.application.config_for(:searchkick)
  if searchkick_config.present?
    ENV['ELASTICSEARCH_URL'] = searchkick_config[:elasticsearch_url]
    config.searchkick_prefix = searchkick_config[:prefix]
  else
    config.searchkick_prefix = Rails.env
  end
end