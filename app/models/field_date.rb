# == Schema Information
#
# Table name: field_dates
#
#  id         :integer          not null, primary key
#  value      :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FieldDate < ActiveRecord::Base
  has_one :custom_field, as: :value
  has_one :field_configuration, as: :default_value

  validates :value, presence: true
  validate :value_format

  def value_format
    if value.present?
      date = Date.strptime(value, "%d %b %Y") rescue nil
      if date.blank?
        self.errors.add :date, 'format is incorrect'
      end
    end
  end
end
