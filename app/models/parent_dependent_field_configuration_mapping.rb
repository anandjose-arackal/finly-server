# == Schema Information
#
# Table name: parent_dependent_field_configuration_mappings
#
#  id                               :integer          not null, primary key
#  parent_id                        :integer
#  parent_type                      :string(255)
#  dependent_field_configuration_id :integer
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#

class ParentDependentFieldConfigurationMapping < ApplicationRecord

  belongs_to :parent, optional: true, polymorphic: true
  belongs_to :dependent_field_configuration, optional: true, class_name: "FieldConfiguration"

end