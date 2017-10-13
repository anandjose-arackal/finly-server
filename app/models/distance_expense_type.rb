class DistanceExpenseType < ActiveRecord::Base
  include Seedable

  validates :name, presence: true

  def self.values
    [:distance, :odometer]
  end

end
