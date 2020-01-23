class TripStatus < ApplicationRecord
  include Seedable

  def self.values
    [:draft, :processing, :retracted, :rejected, :booking_confirmed, :cancelled, :booking_pending,
     :completed, :approved, :auto_approved]
  end

end
