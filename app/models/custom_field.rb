# == Schema Information
#
# Table name: custom_fields
#
#  id                     :integer          not null, primary key
#  field_configuration_id :integer          not null
#  value                  :text(65535)
#  parent_id              :integer          not null
#  parent_type            :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class CustomField < ActiveRecord::Base
  belongs_to :field_configuration
  belongs_to :parent, polymorphic: true

  validate :validate_field

  def validate_field
    errors = FieldConfiguration.valid_field?(self)
    if errors.present?
      self.errors.add errors
    end
  end
end
