# == Schema Information
#
# Table name: master_entity_choices
#
#  id               :bigint           not null, primary key
#  company_id       :integer          not null
#  name             :string(255)      not null
#  position         :integer
#  master_entity_id :string(255)      not null
#  created_by_id    :integer
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  key              :string(255)
#

class MasterEntityChoice < ApplicationRecord

  belongs_to :company
  belongs_to :master_entity
  belongs_to :created_by, class_name: 'User', optional: true

  after_save :set_key

  def set_key
    unless key.present?
      self.key = self.id
      self.save!
    end
  end

  def as_json()
    {
      id: key,
      name: name
    }
  end
end
