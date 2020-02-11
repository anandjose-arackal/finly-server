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
#  deleted_at             :datetime
#  uuid                   :string(36)
#

class FieldDropDownItem < ApplicationRecord
  include SoftDeletable

  belongs_to :field_configuration, optional: true

  has_many :parent_dependent_field_configuration_mappings, foreign_key: :parent_id
  has_many :dependent_field_configurations, through: :parent_dependent_field_configuration_mappings

  has_many :budget_criteria_mappings, as: :budgetable
  has_many :budgets, through: :budget_criteria_mappings

  has_many :user_drop_down_item_mappings , class_name: 'UserDropDownItemMapping', foreign_key: :drop_down_item_id
  has_many :affected_users, through: :user_drop_down_item_mappings, source: :user

  validates :name, presence: true

  scope :with_id, -> (id){ where id: id }
  scope :with_field_configuration_id, -> (id) {
    where field_configuration_id: id
  }
  scope :filter_user_id,->(user_id) do
    joins(:user_drop_down_item_mappings).where('user_drop_down_item_mappings.user_id = ?', user_id)
  end

  scope :filter_user_email_mobile, -> (email_mobile) {
    user_ids = User.with_email_or_mobile_number(email_mobile, email_mobile).pluck(:id)
    joins(:user_drop_down_item_mappings).where('user_drop_down_item_mappings.user_id = ?', user_ids)
  }

  default_scope { unscope(:where) }

  def as_json(options={})
    dependent = dependent_field_configurations
    {
        id: id,
        name: name,
        # dependent_field_configurations: dependent_field_configurations,
        # dependent_cf_present: self.dependent_field_configurations.exists?
        dependent_field_configurations: dependent,
        custom_field_name: self.field_configuration&.field_name,
        dependent_cf_present: dependent.present?
    }
  end

end
