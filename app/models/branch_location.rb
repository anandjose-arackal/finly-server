# == Schema Information
#
# Table name: branch_locations
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  gstin                 :string(255)
#  pan                   :string(255)
#  company_id            :integer
#  address_1             :string(255)
#  address_2             :string(255)
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
#

class BranchLocation < ApplicationRecord
  include SoftDeletable
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
      name: location_name,
    }
  end

  def location_name
    self.parent.blank? ? self.name : "#{self.ancestors&.pluck(:name)&.join(' / ')} / #{self.name}"
  end
end
