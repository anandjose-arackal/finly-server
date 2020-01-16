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

class AdminUserRoleMapping < ApplicationRecord
  belongs_to :admin_user, optional: true
  belongs_to :admin_user_role, optional: true

  scope :admin, -> {where(admin_user_role_id: AdminUserRole.id_for(:admin))}
  scope :transcriber, -> {where(admin_user_role_id: AdminUserRole.id_for(:transcriber))}
  scope :verifier, -> {where(admin_user_role_id: AdminUserRole.id_for(:verifier))}
  scope :itzcash_verifier, -> {where(admin_user_role_id: AdminUserRole.id_for(:itzcash_verifier))}
  scope :itzcash_operations, -> {where(admin_user_role_id: AdminUserRole.id_for(:itzcash_operations))}
  scope :call_center, -> {where admin_user_role_id: AdminUserRole.id_for(:call_center)}

end
