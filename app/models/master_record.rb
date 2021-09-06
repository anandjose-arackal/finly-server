# == Schema Information
#
# Table name: master_records
#
#  id               :bigint           not null, primary key
#  master_schema_id :integer          not null
#  ancestry         :string(255)
#  start_date       :datetime
#  end_date         :datetime
#  company_id       :integer
#  created_by_id    :integer
#  field_1          :string(255)
#  field_2          :string(255)
#  field_3          :string(255)
#  field_4          :string(255)
#  field_5          :string(255)
#  field_6          :string(255)
#  field_7          :string(255)
#  field_8          :string(255)
#  field_9          :string(255)
#  field_10         :string(255)
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class MasterRecord < ApplicationRecord
  include SoftDeletable
  include AncestrySupport
  belongs_to :created_by, class_name: 'User'
  belongs_to :company
  has_ancestry
end
