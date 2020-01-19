# == Schema Information
#
# Table name: cost_centers
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  application      :string(255)
#  company_id       :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  is_deleted       :boolean
#  deleted_at       :datetime
#  cost_center_code :string(255)
#  ancestry         :string(255)
#  gl_code          :string(255)
#  uuid             :string(36)
#

class CostCenter < ApplicationRecord
  include SoftDeletable, AncestrySupport
  include Sequenced::ActsAsSequenced
  include LiquidDroppable
  include EventProducer

  event_channel 'cost_center'

  acts_as_sequenced column: :cost_center_code, purpose: :cost_center, editable: false, prefix: 'CC'

  has_ancestry

  belongs_to :company, optional: true

  has_many :budget_criteria_mappings, as: :budgetable
  has_many :budgets, through: :budget_criteria_mappings

  has_many :departments
  has_many :users

  has_many :budget_trails

  scope :with_name, -> (name) {where name: name}
  scope :with_application, -> (app) {
    where application: app
  }

  scope :vendor_payments_only, -> {
    where application: "vp"
  }

  def as_json(options={})
    {
        id: id,
        name: name
    }
  end

end
