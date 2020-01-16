# == Schema Information
#
# Table name: field_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FieldType < ApplicationRecord

  TYPES = {text: 1, number: 2, decimal: 3, boolean: 4, drop_down: 5, date: 6, datetime: 7, amount: 8, multiselect: 9}

  def self.id_for(sym)
    TYPES[sym]
  end

  def self.name_for(id)
    TYPES.key(id)
  end

  def self.seed_data
    TYPES.each do |name, id|
      unless FieldType.find_by(name: name.to_s)
        FieldType.create(id: id, name: name)
      end
    end
  end

  def drop_down?
    self.id == FieldType.id_for(:drop_down)
  end

  def text?
    self.id == FieldType.id_for(:text)
  end

  def multiselect?
    self.id == FieldType.id_for(:multiselect)
  end

  def as_json(options={})
    {
        id: id,
        name: name
    }
  end

end
