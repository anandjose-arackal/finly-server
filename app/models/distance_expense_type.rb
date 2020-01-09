# == Schema Information
#
# Table name: distance_expense_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DistanceExpenseType < ApplicationRecord
  include Seedable

  validates :name, presence: true

  def self.values
    [:distance, :odometer]
  end

end
