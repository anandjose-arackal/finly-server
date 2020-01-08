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
#

require 'rails_helper'

RSpec.describe ExportTemplate, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
