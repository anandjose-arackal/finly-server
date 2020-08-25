# == Schema Information
#
# Table name: export_template_news
#
#  id                    :bigint           not null, primary key
#  name                  :string(255)      not null
#  description           :text(65535)
#  export_format         :string(255)      not null
#  resource              :string(255)      not null
#  template              :text(4294967295)
#  query                 :text(4294967295)
#  active                :boolean          default(TRUE)
#  personal              :boolean
#  company_id            :integer
#  created_by_id         :integer
#  deleted_at            :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  include_custom_fields :boolean          default(FALSE)
#

class ExportTemplateNew < ApplicationRecord
  belongs_to :company
  belongs_to :created_by, class_name: 'User'
end
