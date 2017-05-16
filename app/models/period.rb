# == Schema Information
#
# Table name: periods
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


class Period < ActiveRecord::Base

  # VALUES = {day: 1, week: 2, fortnight: 3, month: 4, quarter: 5, year: 6}
  VALUES = {day: 1, week: 2, month: 3, quarter: 4, year: 5, hour: 6}

  validates :name, presence: true

  scope :with_name, ->(name) { where name: name }

  def period
    self.name
  end

  def period_name
    self.name
  end

  def self.id_for(item)
    VALUES[item]
  end

  def self.name_for(item)
    VALUES.key(item)
  end

  def self.seed_data
    count = Period.count
    VALUES.each do |key, value|
      if count == 0 or Period.with_name(key).blank?
        Period.create id: value, name: key
      end
    end
  end

end
