# == Schema Information
#
# Table name: export_template_user_role_mappings
#
#  id           :bigint           not null, primary key
#  template_id  :integer
#  user_role_id :integer          not null
#  deleted_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class ExportTemplateUserRoleMapping < ApplicationRecord
  belongs_to :template, class_name: 'ExportTemplateNew', optional: true
  belongs_to :user_role
end
