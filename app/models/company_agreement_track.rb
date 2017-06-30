# == Schema Information
#
# Table name: company_agreement_tracks
#
#  id           :integer          not null, primary key
#  user_id      :integer          not null
#  agreement_id :integer          not null
#  ip_address   :string(255)
#  referrer     :string(255)
#  application  :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class CompanyAgreementTrack < ActiveRecord::Base
  belongs_to :agreement
  belongs_to :user
  belongs_to :company

  scope :with_user, -> (user_id) { where user_id: user_id }
  scope :with_agreement, -> (agreement_id) { where agreement_id: agreement_id }
  scope :with_company, -> (company_id){ where company_id: company_id}
end
