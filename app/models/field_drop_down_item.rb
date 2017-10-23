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
  include SoftDeletable

  belongs_to :field_configuration

  validates :name, presence: true

  scope :with_id, -> (id){ where id: id }

  default_scope { unscope(:where) }

  def as_json(options={})
    {id: id, name: name}
  end

end
