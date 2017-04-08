# == Schema Information
#
# Table name: admin_user_role_mappings
#
#  id                 :integer          not null, primary key
#  admin_user_id      :integer
#  admin_user_role_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class AdminUserRoleMapping < ActiveRecord::Base
  belongs_to :admin_user
  belongs_to :admin_user_role
end
