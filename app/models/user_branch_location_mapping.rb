class UserBranchLocationMapping < ApplicationRecord
  belongs_to :user
  belongs_to :branch_location
end
