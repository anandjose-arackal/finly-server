# == Schema Information
#
# Table name: booking_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BookingStatus < ActiveRecord::Base

  include Seedable

  def self.values
    [:booking_option, :processing, :confirmed, :cancelled]

  end
end
