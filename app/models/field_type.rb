# == Schema Information
#
# Table name: field_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'Date'
class FieldType < ActiveRecord::Base

  TYPES = {text: 1, number: 2, decimal: 3, boolean: 4, drop_down: 5, date: 6, amount: 7}

  def self.id_for(sym)
    TYPES[sym]
  end

  def self.name_for(id)
    TYPES.key(id)
  end

end
