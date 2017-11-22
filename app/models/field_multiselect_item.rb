# == Schema Information
#
# Table name: field_multiselect_items
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  field_configuration_id :integer
#

class FieldMultiselectItem < ActiveRecord::Base

  belongs_to :field_configuration

end
