# == Schema Information
#
# Table name: master_mappings
#
#  id               :bigint           not null, primary key
#  company_id       :integer
#  created_by_id    :integer
#  master_entity_id :integer          not null
#  from_record_id   :integer
#  from_record_type :string(255)
#  to_record_id     :integer
#  to_record_type   :string(255)
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class MasterMapping < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  belongs_to :company

  belongs_to :from_record, polymorphic: true, optional: true
  belongs_to :to_record, polymorphic: true
end
