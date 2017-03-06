# == Schema Information
#
# Table name: field_date_times
#
#  id         :integer          not null, primary key
#  value      :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FieldDateTime < ActiveRecord::Base
  has_one :custom_field, as: :value
  has_one :field_configuration, as: :default_value

  validates :value, presence: true
  validate :value_format

  def value_format
    if value.present?
      # Validate date as 24hour clock format: 20:30, 02 Jun 2016
      date = Date.strptime(value, "%H:%M, %d %b %Y") rescue nil

      # Validate date as 12hour clock format: 08:30 PM, 02 Jun 2016
      date = Date.strptime(value, "%I:%M %p, %d %b %Y") rescue nil if date.blank?

      if date.blank?
        self.errors.add :date, 'format is incorrect'
      end
    end
  end
end
