# == Schema Information
#
# Table name: export_templates
#
#  id                 :bigint           not null, primary key
#  name               :string(255)      not null
#  description        :text(65535)
#  template_type      :string(255)      not null
#  configuration      :text(4294967295)
#  model_class        :string(255)      not null
#  active             :boolean          default(TRUE)
#  personal           :boolean
#  created_by_user_id :integer          not null
#  company_id         :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  uuid               :string(36)
#

class ExportTemplate < ApplicationRecord
  belongs_to :company
  belongs_to :created_by_user, class_name: 'User'

  serialize :configuration, JSON
end
