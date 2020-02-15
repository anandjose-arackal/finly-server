# == Schema Information
#
# Table name: users_with_group_mappings
#
#  id         :bigint           not null, primary key
#  user_id    :integer
#  company_id :integer
#  group_id   :integer
#  uuid       :string(36)
#  deleted_at :datetime
#

class UsersWithGroupMapping < ApplicationRecord
  belongs_to :group, class_name: 'CompanyGroup', foreign_key: 'group_id'
  belongs_to :company
  belongs_to :user

end
