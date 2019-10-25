# == Schema Information
#
# Table name: bbps_biller_subscription_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BbpsBillerSubscriptionStatus < ApplicationRecord
  include Seedable

  def self.values
    %i(draft awaiting_approval retracted rejected approved auto_approved deactivated)
  end

end
