class ApprovalRoute < ActiveRecord::Base
  belongs_to :purpose
  belongs_to :user
  belongs_to :created_by_user, class_name: 'User'
end
