# == Schema Information
#
# Table name: field_amounts
#
#  id         :integer          not null, primary key
#  value_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FieldAmount < ActiveRecord::Base
  has_one :custom_field, as: :value
  has_one :field_configuration, as: :default_value

  belongs_to :value, class_name: 'Amount'

  validates :value_id, presence: true
end
