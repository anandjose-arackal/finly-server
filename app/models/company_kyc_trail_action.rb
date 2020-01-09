# == Schema Information
#
# Table name: company_kyc_trail_actions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


class CompanyKycTrailAction < ApplicationRecord

  include Seedable

  validates :name, presence: true

  def self.values
    [:pending, :retract, :submit, :approve, :final_approve, :upgraded, :reject, :sent_to_itzcash]
  end

end
