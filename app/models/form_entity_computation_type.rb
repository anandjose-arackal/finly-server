# == Schema Information
#
# Table name: form_entity_computation_types
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FormEntityComputationType < ApplicationRecord
  include Seedable

  set_values :form, :lookup

end
