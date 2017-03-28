# == Schema Information
#
# Table name: field_parent_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FieldParentType < ActiveRecord::Base

  TYPES = { expense: 1,
             report: 2,
             money_request: 3 }

  def self.id_for(sym)
    TYPES[sym]
  end

end
