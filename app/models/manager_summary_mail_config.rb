class ManagerSummaryMailConfig < ActiveRecord::Base
  belongs_to :user
  belongs_to :user_mailer_type
  belongs_to :period
end
