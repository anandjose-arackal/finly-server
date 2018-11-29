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
#  field_key              :string(255)
#

class FieldDropDownItem < ActiveRecord::Base
  include SoftDeletable

  belongs_to :field_configuration

  has_many :parent_dependent_field_configuration_mappings, foreign_key: :parent_id
  has_many :dependent_field_configurations, through: :parent_dependent_field_configuration_mappings

  has_many :budget_criteria_mappings, as: :budgetable
  has_many :budgets, through: :budget_criteria_mappings

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
