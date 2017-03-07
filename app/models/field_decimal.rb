# == Schema Information
#
# Table name: field_decimals
#
#  id         :integer          not null, primary key
#  value      :text(65535)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FieldDecimal < ActiveRecord::Base
  has_one :custom_field, as: :value
  has_one :field_configuration, as: :default_value

  validates :value, presence: true
  validate :value_format

  def value_as_decimal
    Float (value)
  end

  protected

  def value_format
    if value.present?
      decimal = Float (value) rescue nil
      if decimal.blank?
        self.errors.add(:value, 'is of invalid format')
      end
    end
  end
end
