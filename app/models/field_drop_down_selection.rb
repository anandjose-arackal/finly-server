# == Schema Information
#
# Table name: field_drop_down_selections
#
#  id         :integer          not null, primary key
#  value_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FieldDropDownSelection < ApplicationRecord
  has_one :custom_field, as: :value
  has_one :field_configuration, as: :default_value
  belongs_to :value, optional: true, class_name: 'FieldDropDownItem'

  validates :value_id, presence: true

  scope :with_value, ->(value_id) { where value_id: value_id }
  scope :with_id, ->(id) { where id: id }

  def as_json(options={})
    {
        id: value_id,
        name: value&.name
    }
  end
end
