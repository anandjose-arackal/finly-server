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

  VALUES = {day: 1, week: 2, fortnight: 3, month: 4, quarter: 5, year: 6}

  validates :name, presence: true

  def period
    self.name
  end

  def self.id_for(item)
    VALUES[item]
  end

  def self.name_for(item)
    VALUES.key(item)
  end

end
