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


  scope :finly_admin, -> {where(admin_user_role_id: AdminUserRole.id_for(:finly_admin))}
  scope :transcriber, -> {where(admin_user_role_id: AdminUserRole.id_for(:transcriber))}

end
