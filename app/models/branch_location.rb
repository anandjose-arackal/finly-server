# == Schema Information
#
# Table name: branch_locations
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  gstin                 :string(255)
#  pan                   :string(255)
#  company_id            :integer
#  address_1             :text(65535)
#  address_2             :text(65535)
#  city                  :string(255)
#  state_id              :integer
#  country               :string(255)
#  pin                   :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  contact_name          :string(255)
#  contact_mobile_number :string(255)
#  is_deleted            :boolean          default(FALSE), not null
#  deleted_at            :datetime
#  location_code         :string(255)
#  ancestry              :string(255)
#  nature_of_office      :string(255)
#  billable_location     :boolean          default(TRUE)
#  shippable_location    :boolean          default(TRUE)
#  gl_code               :string(255)
#

class BranchLocation < ApplicationRecord
  include SoftDeletable, AncestrySupport
  include Sequenced::ActsAsSequenced
  include LiquidDroppable
  include Exposures::Model::Exposable
  include EventProducer
  include SearchIndex::Concerns::Document

  event_channel 'location'

  acts_as_sequenced column: :location_code, purpose: :branch_location, editable: false, prefix: 'LOC'
  has_ancestry

  belongs_to :company, optional: true
  belongs_to :state, optional: true
  has_many :company_location_departments
  has_many :company_departments, through: :company_location_departments

  has_many :budget_trails, as: :location

  has_many :user_branch_location_mappings
  has_many :users, through: :user_branch_location_mappings

  has_many :budget_rule_branch_location_mappings
  has_many :budget_rules, through: :budget_rule_branch_location_mappings

  has_many :users

  scope :with_ids, -> (ids) { where id: ids }
  scope :with_id, -> (id) {where id: id}

  scope :include_state, -> { includes :state }
  default_scope {unscope(:where)}

  def state_code
    self.state&.state_code
  end

  def address
    address = ""
    if self.address_1.present?
      address += (self.address_1 + ",\n")
    end
    if self.address_2.present?
      address += (self.address_2 + ",\n")
    end
    if self.city.present?
      address += (self.city + ", ")
    end
    if self.state.present?
      address += (self.state.name + ",\n")
    end
    if self.pin.present?
      address += (self.pin)
    end
    address
  end

  # def gstin

  # end

  def pin

  end

  # def as_json
  #   {
  #     id: self.id,
  #     name: self.name,
  #     gstin: self.gstin,
  #     pan: self.pan,
  #     address_1: self.address_1,
  #     address_2: self.address_2,
  #     city: self.city,
  #     country: self.country,
  #     pin: self.pin,
  #     address: self.address,
  #     location_code: self.location_code,
  #     parent: [self.parent&.id, self.parent&.name]&.compact
  #   }
  # end

  def as_json2
    {
      id: self.id,
      name: full_name,
    }
  end

  def as_json(options={})
    display_name = options&.dig(:tree) ? full_name : name
    {
        id: self.id,
        name: display_name,
        gstin: self.gstin,
        pan: self.pan,
        address_1: self.address_1,
        address_2: self.address_2,
        city: self.city,
        country: self.country,
        pin: self.pin,
        address: self.address,
        location_code: self.location_code,
        state_code: self.state&.state_code,
        billable: self.billable_location,
        shippable: self.shippable_location,
        state: self.state
    }
  end

  def location_name
    self.parent.blank? ? self.name : "#{self.ancestors&.pluck(:name)&.join(' / ')} / #{self.name}"
  end

  def code
    self.location_code
  end

end
