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

  TYPES = {text: 1, number: 2, decimal: 3, boolean: 4, dropdown: 5, date: 6, amount: 7}

  def self.id_for(sym)
    TYPES[sym]
  end

  def self.name_for(id)
    TYPES.key(id)
  end

  def self.valid_value?(type_id, value)
    key = self.name_for(type_id)
    return :invalid, 'Field Type' if key.blank?
    case key
      when :text
        return value.present?
      when :number
        return nil if Integer (value) rescue nil
        return :given, 'value is not a valid number'
      when :decimal
        return nil if Float (value) rescue nil
        return :given, 'value is not a valid decimal number'
      when :boolean
        StringUtils.to_bool(value).nil? ? return :given, 'value is not a boolean' : return nil
      when :dropdown
        return nil if Integer (value) and FieldDropDownItem.with_id(value).present? rescue nil
        return :selected, 'item not found within the dropdown'
      when :date
        # Validates date format for 12 Apr 2011
        return nil if Date.strptime(value, "%d %b %Y") rescue nil
        return :given, 'date is not a valid date format'
      when :amount
        return nil if Integer (value) and Amount.with_id(value).present? rescue nil
        return :entered, 'amount is invalid format'
    end
    nil
  end

end
