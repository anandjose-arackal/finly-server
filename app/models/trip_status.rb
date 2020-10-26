# == Schema Information
#
# Table name: trip_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  deleted_at :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TripStatus < NonTenantedApplicationRecord
  include Seedable

  def self.values
    [:draft, :processing, :retracted, :rejected, :booking_confirmed, :cancelled, :booking_pending,
     :completed, :approved, :auto_approved]
  end

end
