# == Schema Information
#
# Table name: field_multiselect_items
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  field_configuration_id :integer
#  is_deleted             :boolean
#  deleted_at             :datetime
#

class FieldMultiselectItem < ActiveRecord::Base
  include SoftDeletable

  belongs_to :field_configuration

  default_scope { unscope(:where) }
  
end
