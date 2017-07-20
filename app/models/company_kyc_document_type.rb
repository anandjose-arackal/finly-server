# == Schema Information
#
# Table name: company_kyc_document_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  identifier :string(255)
#

class CompanyKycDocumentType < ActiveRecord::Base


  scope :with_name, -> (name){where name: name}
  scope :with_identifier, -> (identifier) {where identifier: identifier}

  validates :name, presence: true

  def self.values
    [
        {
            name: "Aadhar Card",
            identifier: "aadhar_card"
        },
        {
            name: "PAN Card",
            identifier: "pan_card"
        },
        {
            name: "Certificate of Incorporation",
            identifier: "certificate_of_incorporation"
        },
        {
            name: "Certificate of Registration",
            identifier: "certificate_of_registration"
        },
        {
            name: "List of Partners (in Company Letterhead)",
            identifier: "list_of_partners"
        },
        {
            name: "List of Partners (with DIN)",
            identifier: "list_of_partners_din"
        },
        {
            name: "ID Proof",
            identifier: "id_proof"
        },
        {
            name: "Address Proof",
            identifier: "address_proof"
        },
        {
            name: "Supporting Document",
            identifier: "supporting_document"
        },
        {
            name: "Partnership Deed",
            identifier: "partnership_deed"
        },
        {
            name: "Trust Deed",
            identifier: "trust_deed",
        },
        {
            name: "List of Trustees / Office Bearers / Karta along with Partners",
            identifier: "list_of_trustees_karta"
        }
    ]
  end

  def self.seed_data
    self.values.each do |type|
      if CompanyKycDocumentType.with_name(type[:name]).blank?
        CompanyKycDocumentType.create(name: type[:name], identifier: type[:identifier])
      end
    end
  end

  def self.id_for(name)
    obj = CompanyKycDocumentType.with_name(name).first
    obj.id
  end

  def self.name_for(identifier)
    obj = CompanyKycDocumentType.with_identifier(identifier).first
    obj.name
  end

end
