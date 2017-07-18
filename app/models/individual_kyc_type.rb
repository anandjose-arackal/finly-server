# == Schema Information
#
# Table name: individual_kyc_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class IndividualKycType < ActiveRecord::Base
  include Seedable

  def self.values
    [:aadhar_card, :driving_license, :voter_id, :ngera_job_card, :passport]
  end

end
