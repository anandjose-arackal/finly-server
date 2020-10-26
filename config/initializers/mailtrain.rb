Rails.application.configure do
  mail_train_config = Rails.application.config_for(:mailtrain)
  config.mailtrain = OpenStruct.new
  if config.present?
    config.mailtrain.client = Mailtrain::Client.new(mail_train_config[:url], mail_train_config[:access_token])
    config.mailtrain.customers_list = mail_train_config[:customers_list]
  end
end