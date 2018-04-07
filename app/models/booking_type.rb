# == Schema Information
#
# Table name: booking_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BookingType < ActiveRecord::Base
  include Seedable

  def self.values
    [:booking, :booking_request]
  end

end
