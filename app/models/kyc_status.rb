# == Schema Information
#
# Table name: kyc_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class KycStatus < ActiveRecord::Base
  include Seedable

  def self.values
    [:incomplete, :submitted, :processing, :rejected, :approved]
  end

end
