# == Schema Information
#
# Table name: custom_fields
#
#  id                     :integer          not null, primary key
#  field_configuration_id :integer          not null
#  parent_id              :integer          not null
#  parent_type            :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  value_id               :integer          not null
#  value_type             :string(255)      not null
#

class CustomField < ActiveRecord::Base
  belongs_to :field_configuration
  belongs_to :parent, polymorphic: true
  belongs_to :value, polymorphic: true

  validate :validate_field

  validates :value_id, presence: true
  validates :value_type, presence: true, :inclusion =>  {:in => ['FieldAmount', 'FieldBoolean', 'FieldDate', 'FieldDateTime', 'FieldDecimal', 'FieldDropDownSelection', 'FieldNumber', 'FieldText']}

  def validate_field
    result = CustomField::Validate.(self)
    unless result.success?
      result.messages[:error].each do |error|
        self.errors.add :error, error
      end
    end
  end
end
