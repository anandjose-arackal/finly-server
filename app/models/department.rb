# == Schema Information
#
# Table name: departments
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  company_id     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  is_deleted     :boolean          default(FALSE), not null
#  ancestry       :string(255)
#  cost_center_id :integer
#  deleted_at     :datetime
#

class Department < ApplicationRecord
  include SoftDeletable
  has_ancestry
  belongs_to :company, optional: true
  belongs_to :cost_center, optional: true

  has_many :user_department_mappings
  has_many :users, through: :user_department_mappings
  
  has_many :budget_rule_department_mappings
  has_many :budget_rules, through: :budget_rule_department_mappings

  has_many :cost_center_department_mappings
  has_many :cost_centers, through: :cost_center_department_mappings

  accepts_nested_attributes_for :user_department_mappings

  scope :with_ids, -> (id) { where id: id }
  scope :with_name, -> (name) {where name: name}
  # scope :only_sub_departments, -> {
  #   where(id: Department.pluck(:ancestry).compact.map { |e| e.split('/') }.flatten.uniq)
  # }

  scope :filter_name, -> (name) {
    where("departments.name like ?", "%#{name}%")
  }

  scope :filter_only_roots, -> {
    where("departments.ancestry IS NULL")
  }
  scope :only_sub_departments, -> {
    where("departments.ancestry IS NOT NULL")
  }

  def as_json(options={})
    {
        id: id,
        name: name
    }
  end

end
