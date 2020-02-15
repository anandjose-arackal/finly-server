# == Schema Information
#
# Table name: trip_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  deleted_at :datetime
#

class TripStatus < ApplicationRecord
  include Seedable

  def self.values
    [:draft, :processing, :retracted, :rejected, :booking_confirmed, :cancelled, :booking_pending,
     :completed, :approved, :auto_approved]
  end

end
