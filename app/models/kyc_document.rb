# == Schema Information
#
# Table name: kyc_documents
#
#  id                           :integer          not null, primary key
#  company_kyc_document_type_id :integer
#  company_kyc_id               :integer
#  doc_file_name                :string(255)
#  doc_content_type             :string(255)
#  doc_file_size                :integer
#  doc_updated_at               :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  identifier                   :string(255)
#

class KycDocument < ActiveRecord::Base
  include Attachable

  belongs_to :company_kyc_document_type
  belongs_to :company_kyc

  has_many :system_messages

  CONTENT_TYPES = {content_type: %w(image/jpg image/jpeg image/png image/gif application/pdf application/rtf)}

  has_attached_file :doc, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :doc, content_type: CONTENT_TYPES

  scope :pan_card, -> {where company_kyc_document_type_id: CompanyKycDocumentType.id_for('Pan Card')}
  scope :aadhar_card, -> {where company_kyc_document_type_id: CompanyKycDocumentType.id_for('Aadhar Card')}
  scope :certificate_of_incorporation, -> {where company_kyc_document_type_id: CompanyKycDocumentType.id_for('Certificate of Incorporation')}
  scope :certificate_of_registration, -> {where company_kyc_document_type_id: CompanyKycDocumentType.id_for('Certificate of Registration')}
  scope :list_of_partners, -> {where company_kyc_document_type_id: CompanyKycDocumentType.id_for('List of Partners (in Company Letterhead)')}
  scope :list_of_partners_din, -> {where company_kyc_document_type_id: CompanyKycDocumentType.id_for('List of Partners (with DIN)')}
  scope :id_proof, -> {where company_kyc_document_type_id: CompanyKycDocumentType.id_for('ID Proof')}
  scope :address_proof, -> {where company_kyc_document_type_id: CompanyKycDocumentType.id_for('Address Proof')}
  scope :supporting_document, -> {where company_kyc_document_type_id: CompanyKycDocumentType.id_for('Supporting Document')}
  scope :partnership_deed, -> {where company_kyc_document_type_id: CompanyKycDocumentType.id_for('Partnership Deed')}
  scope :trust_deed, -> {where company_kyc_document_type_id: CompanyKycDocumentType.id_for('Trust Deed')}
  scope :list_of_trustees_karta, -> {where company_kyc_document_type_id: CompanyKycDocumentType.id_for('List of Trustees / Office Bearers / Karta along with Partners')}

end
