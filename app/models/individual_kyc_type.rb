# == Schema Information
#
# Table name: individual_kyc_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class IndividualKycType < ApplicationRecord
  include Seedable

  def self.values
    [:aadhar_card, :driving_license, :voter_id, :ngera_job_card, :passport]
  end

  def aadhar_card?
    self.id == IndividualKycType.id_for(:aadhar_card)
  end

  def driving_license?
    self.id == IndividualKycType.id_for(:driving_license)
  end

  def voter_id?
    self.id == IndividualKycType.id_for(:voter_id)
  end

  def ngera_job_card?
    self.id == IndividualKycType.id_for(:ngera_job_card)
  end

  def passport?
    self.id == IndividualKycType.id_for(:passport)
  end

end
