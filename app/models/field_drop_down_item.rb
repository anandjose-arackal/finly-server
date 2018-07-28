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
  has_many :dependent_field_configurations, class_name: "FieldConfiguration", as: :parent

  has_many :budget_entity_mappings, as: :budgetable
  has_many :budgets, through: :budget_entity_mappings

  validates :name, presence: true

  scope :with_id, -> (id){ where id: id }
  scope :with_field_configuration_id, -> (id) {
    where field_configuration_id: id
  }

  default_scope { unscope(:where) }

  def as_json(options={})
    {
        id: id,
        name: name,
        dependent_field_configurations: dependent_field_configurations,
        dependent_cf_present: self.dependent_field_configurations.present?
    }
  end

end