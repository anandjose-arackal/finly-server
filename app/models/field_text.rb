# == Schema Information
#
# Table name: field_texts
#
#  id         :integer          not null, primary key
#  value      :text(65535)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FieldText < ApplicationRecord
  has_one :custom_field, as: :value
  has_one :field_configuration, as: :default_value

  validates :value, presence: true

  def as_json
    {value: self.value}
  end
end
