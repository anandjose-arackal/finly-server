class PolicyUserRole < ActiveRecord::Base
  belongs_to :policy
  belongs_to :user
  belongs_to :user_role
end
