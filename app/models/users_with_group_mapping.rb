class UsersWithGroupMapping < ApplicationRecord
  belongs_to :group, class_name: 'CompanyGroup', foreign_key: 'group_id'
  belongs_to :company
  belongs_to :user

end