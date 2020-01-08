# == Schema Information
#
# Table name: company_kyc_trails
#
#  id                   :integer          not null, primary key
#  company_kyc_id       :integer
#  action_resource_id   :integer
#  action_resource_type :string(255)
#  action_id            :integer
#  note                 :text(65535)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class CompanyKycTrail< ApplicationRecord
  belongs_to :company_kyc, optional: true
  belongs_to :action_resource, optional: true, polymorphic: true
  belongs_to :action, optional: true, class_name: "CompanyKycTrailAction"

  validates :company_kyc_id, presence: true
  validates :action_id, presence: true
end
