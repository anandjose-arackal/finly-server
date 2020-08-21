# == Schema Information
#
# Table name: departments
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  company_id      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  is_deleted      :boolean          default(FALSE), not null
#  parent_id       :string(255)
#  cost_center_id  :integer
#  deleted_at      :datetime
#  department_code :string(255)
#  code            :string(255)
#  gl_code         :string(255)
#  start_date      :date
#  end_date        :date
#

class Department < ApplicationRecord
  include SoftDeletable, AncestrySupport
  include Sequenced::ActsAsSequenced
  include LiquidDroppable
  include Exposures::Model::Exposable
  include EventProducer

  event_channel 'department'

  acts_as_sequenced column: :department_code, purpose: :department, editable: false, prefix: 'DPT'

  has_ancestry ancestry_column: :parent_id

  # This is support for old attributes which we were renamed during the masters generalization
  alias_attribute :ancestry, :parent_id

  belongs_to :company, optional: true
  belongs_to :cost_center, optional: true

  has_many :user_department_mappings
  has_many :users, through: :user_department_mappings

  has_many :budget_rule_department_mappings
  has_many :budget_rules, through: :budget_rule_department_mappings

  has_many :cost_center_department_mappings
  has_many :cost_centers, through: :cost_center_department_mappings
  has_many :users


  accepts_nested_attributes_for :user_department_mappings

  default_scope { unscope(:where) }

  scope :with_ids, -> (id) { where id: id }
  scope :with_id, -> (id) { where id: id }

  scope :with_name, -> (name) { where name: name }
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

  def code
    self.department_code
  end


  def as_json(options = {})
    args = {id: self.id}
    args[:name] = options&.dig(:tree) ? full_name : name
    # args[:name] = name if ancestry.present?
    args[:code] = department_code
    args[:department_code] = department_code
    # args[:cost_center] = self.cost_center
    # if options&.dig(:tree)
    #   args[:name] = full_name
    #   args[:cost_center] = self.cost_center
    # else
    #   args[:name] = name
    # end
    args
  end

  def full_dept_name
    # self.parent.blank? ? self.name : "#{self.parent&.name} / #{self.name}"
    self.parent.blank? ? self.name : "#{self.ancestors&.pluck(:name)&.join(' / ')} / #{self.name}"
  end


end
