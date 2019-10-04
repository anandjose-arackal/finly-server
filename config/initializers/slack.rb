if File.exists?("#{Rails.root}/config/mattermost_config.yml")
  mattermost_config = Rails.application.config_for(:mattermost_config)
  webhook = mattermost_config&.dig("webhook")

  if webhook
    SLACK_NOTIFIER = Slack::Notifier.new webhook do
      defaults channel: "#system_alert",
               username: "system_alert"
    end
  end
end