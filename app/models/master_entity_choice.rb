# == Schema Information
#
# Table name: master_entity_choices
#
#  id               :bigint           not null, primary key
#  uuid             :string(36)       not null
#  company_id       :integer          not null
#  name             :string(255)      not null
#  position         :integer
#  master_entity_id :string(255)      not null
#  created_by_id    :integer
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class MasterEntityChoice < ApplicationRecord
  belongs_to :company
  belongs_to :master_entity
  belongs_to :created_by, class_name: 'User', optional: true
end
