# == Schema Information
#
# Table name: field_drop_down_items
#
#  id                     :integer          not null, primary key
#  name                   :string(255)      not null
#  field_configuration_id :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class FieldDropDownItem < ActiveRecord::Base
  belongs_to :field_configuration

  validates :name, presence: true

  scope :with_id, -> (id){ where id: id }
end
