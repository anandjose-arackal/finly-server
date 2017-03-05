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
    result = CustomField::Validate.(self)
    unless result.success?
      result.messages[:errors].each do |error|
        self.errors.add :error, error
      end
    end
  end
end
