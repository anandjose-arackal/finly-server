# == Schema Information
#
# Table name: company_kycs
#
#  id                                        :integer          not null, primary key
#  pan_card_file_name                        :string(255)
#  pan_card_content_type                     :string(255)
#  pan_card_file_size                        :integer
#  pan_card_updated_at                       :datetime
#  coi_file_name                             :string(255)
#  coi_content_type                          :string(255)
#  coi_file_size                             :integer
#  coi_updated_at                            :datetime
#  board_resolution_file_name                :string(255)
#  board_resolution_content_type             :string(255)
#  board_resolution_file_size                :integer
#  board_resolution_updated_at               :datetime
#  kyc_status_id                             :integer
#  company_id                                :integer          not null
#  created_at                                :datetime         not null
#  updated_at                                :datetime         not null
#  date_of_establishment                     :date
#  street_2                                  :text(65535)
#  street_3                                  :text(65535)
#  registered_mobile_number                  :string(255)
#  pan_card_no                               :string(255)
#  pin_code                                  :string(255)
#  city_code                                 :string(255)
#  aadhar_card_file_name                     :string(255)
#  aadhar_card_content_type                  :string(255)
#  aadhar_card_file_size                     :integer
#  aadhar_card_updated_at                    :datetime
#  vat_registration_certificate_file_name    :string(255)
#  vat_registration_certificate_content_type :string(255)
#  vat_registration_certificate_file_size    :integer
#  vat_registration_certificate_updated_at   :datetime
#  registration_of_trust_file_name           :string(255)
#  registration_of_trust_content_type        :string(255)
#  registration_of_trust_file_size           :integer
#  registration_of_trust_updated_at          :datetime
#  driving_licence_file_name                 :string(255)
#  driving_licence_content_type              :string(255)
#  driving_licence_file_size                 :integer
#  driving_licence_updated_at                :datetime
#  passport_file_name                        :string(255)
#  passport_content_type                     :string(255)
#  passport_file_size                        :integer
#  passport_updated_at                       :datetime
#  company_type_id                           :integer
#  certificate_of_registration_file_name     :string(255)
#  certificate_of_registration_content_type  :string(255)
#  certificate_of_registration_file_size     :integer
#  certificate_of_registration_updated_at    :datetime
#  customer_type_id                          :integer
#  customer_id                               :string(255)
#  authorized_signatory_aadhar_file_name     :string(255)
#  authorized_signatory_aadhar_content_type  :string(255)
#  authorized_signatory_aadhar_file_size     :integer
#  authorized_signatory_aadhar_updated_at    :datetime
#

class CompanyKyc < ActiveRecord::Base
  include Attachable

  belongs_to :company
  belongs_to :kyc_status
  belongs_to :company_type
  has_many :system_messages, as: :messagable, dependent: :destroy
  has_many :kyc_documents

  accepts_nested_attributes_for :system_messages

  CONTENT_TYPES = {content_type: %w(image/jpg image/jpeg image/png image/gif application/pdf application/rtf)}

  has_attached_file :coi, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :coi, content_type: CONTENT_TYPES

  has_attached_file :pan_card, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :pan_card, content_type: CONTENT_TYPES

  has_attached_file :passport, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :passport, content_type: CONTENT_TYPES

  has_attached_file :driving_licence, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :driving_licence, content_type: CONTENT_TYPES

  has_attached_file :aadhar_card, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :aadhar_card, content_type: CONTENT_TYPES

  has_attached_file :vat_registration_certificate, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :vat_registration_certificate, content_type: CONTENT_TYPES

  has_attached_file :registration_of_trust, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :registration_of_trust, content_type: CONTENT_TYPES

  has_attached_file :certificate_of_registration, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :certificate_of_registration, content_type: CONTENT_TYPES

  validate :pin_code_format

  def editable?
    [KycStatus.id_for(:incomplete), KycStatus.id_for(:submitted), KycStatus.id_for(:rejected)].include?(kyc_status_id)
  end

  def processing?
    if self.kyc_status_id == KycStatus.id_for(:processing)
      return true
    end
    false
  end

  def submitted?
    if self.kyc_status_id == KycStatus.id_for(:submitted)
      return true
    end
    false
  end

  def completed?
    if self.kyc_status_id == KycStatus.id_for(:completed)
      return true
    end
    false
  end

  def city_code
    pin = self.pin_code
    city_id = PinCodeCityIdMapping.find_by(pin_code: pin)
    city_code = CityIdCityCodeMapping.find_by(city_id: city_id)
  end

  def required_documents
    docs = []
    docs << "pan_card"
    case self.company_type_id
      when CompanyType.id_for('Sole Proprietor')
        # nothing else, lol
      when CompanyType.id_for('Private Ltd Company')
        docs << "certificate_of_incorporation"
      when CompanyType.id_for('Partnership Firm')
        docs << "certificate_of_registration"
    end
  end

  def required_document_files
    documents = []
    # irrespective of company type, all companies need pan card
    pan_card = {}
    pan_card[:name] = "PAN Card"
    file = {}
    if self.kyc_documents.pan_card.present?
      file = {
          type: company_kyc.kyc_documents.pan_card.first.doc_content_type,
          original: company_kyc.kyc_documents.pan_card.first.doc.url,
          thumb: company_kyc.kyc_documents.pan_card.first.doc.url(:thumb)
      }
    end
    system_messages = nil
    if company_kyc.system_messages.pan_card_messages.present?
      system_messages = company_kyc.system_messages.pan_card_messages
    end
    pan_card[:options] = []
    pan_card[:options] << {
        identifier: "pan_card",
        name: "PAN Card",
        uploaded: company_kyc.kyc_documents.pan_card.present?,
        file: file,
        system_messages: system_messages&.pluck(:content),
    }
    documents << pan_card
    # now based on company type, the other document is decided
    case self.company_type_id
      when CompanyType.id_for('Sole Proprietor')
        # sole proprietor
        supporting_doc = {}
        supporting_doc[:name] = "ID Proof"
        supporting_doc[:options] = sole_proprietor_supporting_documents
        documents << supporting_doc
        supporting_doc[:name] = "Address Proof"
        supporting_doc[:options] = sole_proprietor_supporting_documents
        documents << supporting_doc

      when 3, 5
        address_proof = {}
        address_proof[:name] = "Address Proof"
        address_proof[:options] = []
        address_proof[:options] << {
            identifier: "coi",
            name: "Certificate of Incorporation",
            uploaded: company_kyc.coi.present?
        }
        if company_kyc.coi.present?
          file = {
              type: (company_kyc.coi_content_type),
              original: (company_kyc.coi&.url),
              thumb: (company_kyc.coi&.url(:thumb))
          }
          address_proof[:options][0][:file] = file
        end
        if company_kyc.system_messages.coi_messages.present?
          system_messages = company_kyc.system_messages.coi_messages
          address_proof[:options][0][:system_messages] = system_messages&.pluck(:content)
        end
        docs << address_proof
      when 2, 4
        address_proof = {}
        address_proof[:name] = "Address Proof"
        address_proof[:options] = []
        address_proof[:options] << {
            identifier: "certificate_of_registration",
            name: "Certificate of Registration",
            uploaded: company_kyc.certificate_of_registration.present?
        }
        if company_kyc.certificate_of_registration.present?
          file = {
              type: (company_kyc.certificate_of_registration_content_type),
              original: (company_kyc.certificate_of_registration&.url),
              thumb: (company_kyc.certificate_of_registration&.url(:thumb))
          }
          address_proof[:options][0][:file] = file
        end
        if company_kyc.system_messages.certificate_of_registration_messages.present?
          system_messages = company_kyc.system_messages.certificate_of_registration_messages
          address_proof[:options][0][:system_messages] = system_messages&.pluck(:content)
        end
        docs << address_proof
      when 6
        address_proof = {}
        address_proof[:name] = "Address Proof"
        address_proof[:options] = []
        address_proof[:options] << {
            identifier: "registration_of_trust",
            name: "Registration of Trust",
            uploaded: company_kyc.registration_of_trust.present?
        }
        if company_kyc.registration_of_trust.present?
          file = {
              type: (company_kyc.registration_of_trust_content_type),
              original: (company_kyc.registration_of_trust&.url),
              thumb: (company_kyc.registration_of_trust&.url(:thumb))
          }
          address_proof[:options][0][:file] = file
        end
        if company_kyc.system_messages.registration_of_trust_messages.present?
          system_messages = company_kyc.system_messages.registration_of_trust_messages
          address_proof[:options][0][:system_messages] = system_messages&.pluck(:content)
        end
        docs << address_proof
    end
    documents
  end

  private

  def pin_code_format
    if self.pin_code.present?
      unless self.pin_code =~ Constants::VALID_PIN_CODE
        errors.add(:pin_code, "is invalid")
      end
    end
  end

  def sole_proprietor_supporting_documents
    options = []
    id_proof_options = ["Aadhar Card", "VAT Registration Certificate", "CST Registration Certificate", "Service Tax Registration Certificate", "Shops and Establishments Licence",
                                   "Ration Card", "Passport", "Voters ID Card"]
    id_proof_options.each do |option|
      option = {
          identifier: "id_proof",
          name: option,
          uploaded: company_kyc.kyc_documents.id_proof.first.present?
      }
      file = {}
      if self.kyc_documents.id_proof.present?
        file = {
            type: company_kyc.kyc_documents.id_proof.first.doc_content_type,
            original: company_kyc.kyc_documents.id_proof.first.doc.url,
            thumb: company_kyc.kyc_documents.id_proof.first.doc.url(:thumb)
        }
      end
      option[:file] = file
      if self.system_messages.id_proof_messages.present?
        option[:system_messages] = self.system_messages.id_proof_messages.pluck(:content)
      end
      options << option
    end

    address_proof_options = ["Aadhar Card", "VAT Registration Certificate", "CST Registration Certificate", "Service Tax Registration Certificate", "Shops and Establishments Licence",
                             "Ration Card", "Passport", "Voters ID Card"]
    address_proof_options.each do |option|
      option = {
          identifier: "id_proof",
          name: option,
          uploaded: company_kyc.kyc_documents.address_proof.first.present?
      }
      file = {}
      if self.kyc_documents.address_proof.present?
        file = {
            type: company_kyc.kyc_documents.address_proof.first.doc_content_type,
            original: company_kyc.kyc_documents.address_proof.first.doc.url,
            thumb: company_kyc.kyc_documents.address_proof.first.doc.url(:thumb)
        }
      end
      option[:file] = file
      if self.system_messages.address_proof_messages.present?
        option[:system_messages] = self.system_messages.address_proof_messages.pluck(:content)
      end
      options << option
    end

    options
  end

  def partnership_firm_supporting_documents
    options = []
    supporting_document_options = ["Utility Bills (not older than 2 months)", "VAT Registration Certificate", "CST Registration Certificate", "Service Tax Registration Certificate", "Shops and Establishments Licence"]
    supporting_document_options.each do |option|
      option = {
          identifier: "supporting_document",
          name: option,
          uploaded: company_kyc.kyc_documents.supporting_document.first.present?
      }
      file = {}
      if self.kyc_documents.supporting_document.present?
        file = {
            type: company_kyc.kyc_documents.supporting_document.first.doc_content_type,
            original: company_kyc.kyc_documents.supporting_document.first.doc.url,
            thumb: company_kyc.kyc_documents.supporting_document.first.doc.url(:thumb)
        }
      end
      option[:file] = file
      if self.system_messages.supporting_document_messages.present?
        option[:system_messages] = self.system_messages.supporting_document_messages.pluck(:content)
      end
      options << option
    end
    options
  end

  alias_method :llp_supporting_documents, :partnership_firm_supporting_documents
  alias_method :trust_societies_supporting_documents, :partnership_firm_supporting_documents

end
