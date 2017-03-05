# == Schema Information
#
# Table name: field_configurations
#
#  id                   :integer          not null, primary key
#  enabled              :boolean          default(TRUE), not null
#  field_type_id        :integer          not null
#  mandatory            :boolean          default(FALSE), not null
#  company_id           :integer          not null
#  field_parent_type_id :integer          not null
#  configurable_id      :integer          not null
#  configurable_type    :string(255)      not null
#  default_value        :text(65535)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class FieldConfiguration < ActiveRecord::Base
  belongs_to :field_type
  belongs_to :company
  belongs_to :field_parent_type
  # Applicable for User, Policy, Company
  belongs_to :configurable, polymorphic: true

  has_many :drop_down_items, class_name: 'FieldDropDownItem'
  has_many :custom_fields

  validates :field_name, presence: true
  validates :enabled, presence: true
  validates :field_type_id, presence: true
  validates :mandatory, presence: true
  validates :company_id, presence: true
  validates :field_parent_type_id, presence: true
  validates :configurable_id, presence: true
  validates :configurable_type, presence: true, :inclusion=> { :in => ['Police', 'Company', 'User'] }
  validate :validate_config

  def validate_config
    case field_type_id
      when FieldType.id_for(:dropdown)
        if drop_down_items.blank?
          self.errors.add(:dropdown, 'cannot be empty')
        end
    end
    if default_value.present?
      error = FieldType.valid_value?(field_type_id, default_value)
      if error.present?
        self.errors.add error
      end
    end
  end

  def self.valid_field?(field)

  end
end
