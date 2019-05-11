SLACK_NOTIFIER = Slack::Notifier.new "https://hooks.slack.com/services/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" do
  defaults channel: "#system_alert",
           username: "system_alert"
end