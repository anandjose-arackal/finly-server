class ApplicationMailbox < ActionMailbox::Base
  # routing /something/i => :somewhere
  before_processing :log_incoming
  routing  :all => :MailApproval

  def log_incoming
    loggy = Logger.new("#{Rails.root}/logs/incoming_emails.log")
    loggy.debug "Received: #{mail_params[:headers][:subject]} for #{mail_params[:envelope][:to]}"
  end
end