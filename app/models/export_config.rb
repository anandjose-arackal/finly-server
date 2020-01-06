# == Schema Information
#
# Table name: export_configs
#
#  id                    :integer          not null, primary key
#  company_id            :integer          not null
#  export_config_type_id :integer          not null
#  field_reference_id    :integer
#  field_reference_type  :string(255)
#  order                 :integer
#  field_name            :string(255)
#  spreadsheet           :boolean          default(TRUE)
#  pdf                   :boolean          default(TRUE)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class ExportConfig < ApplicationRecord
  belongs_to :company, optional: true
  belongs_to :export_config_type, optional: true

  scope :with_field_name, ->(name) {where field_name: name}

  validates :field_name, presence: true
  validates :export_config_type_id, presence: true
  validates :company_id, presence: true

end
