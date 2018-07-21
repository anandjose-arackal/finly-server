# Load the Rails application.
require File.expand_path('../application', __FILE__)

# if Rails.env.production?
#   ActionMailer::Base.smtp_settings = {
#       :user_name => 'vivekagb',
#       :password => 'idAr5APhk61X',
#       :domain => 'www.finly.io',
#       :address => 'smtp.sendgrid.net',
#       :port => 587,
#       :authentication => :plain,
#       :enable_starttls_auto => true
#   }
# end

# Initialize the Rails application.
Rails.application.initialize!
