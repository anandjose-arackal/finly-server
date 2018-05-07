# == Schema Information
#
# Table name: field_drop_down_items
#
#  id                     :integer          not null, primary key
#  name                   :string(255)      not null
#  field_configuration_id :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  is_deleted             :boolean          default(FALSE)
#

class FieldDropDownItem < ActiveRecord::Base
  include SoftDeletable

  belongs_to :field_configuration
  has_one :dependent_field_configuration, class_name: "FieldConfiguration", as: :parent

  validates :name, presence: true

  scope :with_id, -> (id){ where id: id }
  scope :with_field_configuration_id, -> (id) {
    where field_configuration_id: id
  }

  default_scope { unscope(:where) }

  def as_json(options={})
    result = {id: id, name: name}
    if self.dependent_field_configuration.present?
      result[:dependant_cf_present] = true
    end
    return result
  end

end
