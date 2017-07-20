# == Schema Information
#
# Table name: company_kyc_document_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CompanyKycDocumentType < ActiveRecord::Base

  include Seedable

  validates :name, presence: true

  def self.values
    ['Aadhar Card', 'PAN Card', 'Certificate of Incorporation', 'Certificate of Registration', 'List of Partners (in Company Letterhead)', 'List of Partners (with DIN)', 'ID Proof', 'Address Proof',
     'Supporting Document', 'Partnership Deed', 'Trust Deed']
  end
end
