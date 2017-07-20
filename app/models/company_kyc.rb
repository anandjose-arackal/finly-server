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
  accepts_nested_attributes_for :kyc_documents

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
          type: self.kyc_documents.pan_card.first.doc_content_type,
          original: self.kyc_documents.pan_card.first.doc.url,
          thumb: self.kyc_documents.pan_card.first.doc.url(:thumb)
      }
    end
    system_messages = nil
    if self.system_messages.pan_card_messages.present?
      system_messages = self.system_messages.pan_card_messages
    end
    pan_card[:options] = []
    pan_card[:options] << {
        identifier: "pan_card",
        name: "PAN Card",
        uploaded: self.kyc_documents.pan_card.present?,
        file: file,
        system_messages: system_messages&.pluck(:content),
    }
    documents << pan_card

    # now based on company type, the other document is decided
    case self.company_type_id
      when CompanyType.id_for('Sole Proprietor')
        # sole proprietor
        supporting_doc1 = {}
        supporting_doc1[:name] = "ID Proof"
        supporting_doc1[:options] = sole_proprietor_id_proof_documents
        documents << supporting_doc1

        supporting_doc2 = {}
        supporting_doc2[:name] = "Address Proof"
        supporting_doc2[:options] = sole_proprietor_address_proof_documents
        documents << supporting_doc2

      ## PARTNERSHIP FIRM ##
      when CompanyType.id_for('Partnership Firm')
        # Document 1 - Partnership Deed or Certificate of Registration
        partnership_deed = {}
        partnership_deed[:name] = "Partnership Deed / Certificate of Registration"
        partnership_deed[:options] = []
        partnership_deed[:options] << {
            identifier: "partnership_deed",
            name: "Partnership Deed",
            uploaded: self.kyc_documents.partnership_deed.present?
        }
        if self.kyc_documents.partnership_deed.present?
          file = {
              type: (self.kyc_documents.partnership_deed.first.doc_content_type),
              original: (self.kyc_documents.partnership_deed.first.doc.url),
              thumb: (self.kyc_documents.partnership_deed.first.url(:thumb))
          }
          partnership_deed[:options][0][:file] = file
        end
        if self.system_messages.partnership_deed_messages.present?
          system_messages = self.system_messages.partnership_deed_messages
          partnership_deed[:options][0][:system_messages] = system_messages&.pluck(:content)
        end

        partnership_deed[:options] << {
            identifier: "certificate_of_registration",
            name: "Certificate of Registration",
            uploaded: self.kyc_documents.certificate_of_registration.present?
        }
        if self.kyc_documents.kyc_documents.certificate_of_registration.present?
          file = {
              type: (self.kyc_documents.certificate_of_registration.first.doc_content_type),
              original: (self.kyc_documents.certificate_of_registration.first.doc.url),
              thumb: (self.kyc_documents.certificate_of_registration.first.url(:thumb))
          }
          partnership_deed[:options][1][:file] = file
        end
        if self.system_messages.certificate_of_registration_messages.present?
          system_messages = self.system_messages.certificate_of_registration_messages
          partnership_deed[:options][1][:system_messages] = system_messages&.pluck(:content)
        end

        documents << partnership_deed

        # Document 2 - List of Partners on Company Letterhead
        list_of_partners = {}
        list_of_partners[:name] = "List of Partners with DIN"
        list_of_partners[:options] = []
        list_of_partners[:options] << {
            identifier: "list_of_partners",
            name: "List of Partners on Company Letterhead",
            uploaded: self.list_of_partners.present?
        }
        if self.kyc_documents.list_of_partners.present?
          file = {
              type: (self.kyc_documents.list_of_partners.first.doc_content_type),
              original: (self.kyc_documents.list_of_partners.first.doc.url),
              thumb: (self.kyc_documents.list_of_partners.first.doc.url(:thumb))
          }
          list_of_partners[:options][0][:file] = file
        end
        if self.system_messages.list_of_partners_messages.present?
          system_messages = self.system_messages.list_of_partners_messages
          list_of_partners[:options][0][:system_messages] = system_messages&.pluck(:content)
        end

        documents << list_of_partners

        # Document 3 - One of the supporting documents
        supporting_documents = {}
        supporting_documents[:name] = "Supporting Documents"
        supporting_documents[:options] = partnership_firm_supporting_documents

        documents << supporting_documents

      ## PRIVATE LIMITED COMPANY ##
      when CompanyType.id_for('Private Ltd Company')

        certificate_of_incorporation = {}
        certificate_of_incorporation[:name] = "Certificate of Incorporation"
        certificate_of_incorporation[:options] = []
        certificate_of_incorporation[:options] << {
            identifier: "certificate_of_incorporation",
            name: "Certificate of Incorporation",
            uploaded: self.certificate_of_incorporation.present?
        }
        if self.kyc_documents.certificate_of_incorporation.present?
          file = {
              type: (self.kyc_documents.certificate_of_incorporation.first.doc_content_type),
              original: (self.kyc_documents.certificate_of_incorporation.first.doc.url),
              thumb: (self.kyc_documents.certificate_of_incorporation.first.doc.url(:thumb))
          }
          certificate_of_incorporation[:options][0][:file] = file
        end
        if self.system_messages.certificate_of_incorporation_messages.present?
          system_messages = self.system_messages.certificate_of_incorporation_messages
          certificate_of_incorporation[:options][0][:system_messages] = system_messages&.pluck(:content)
        end
        documents << certificate_of_incorporation

      ## LIMITED LIABILITY PARTNERSHIP ##
      when CompanyType.id_for('Ltd Liability Partnership')

        # Document 1 - Certificate of Incorporation
        certificate_of_incorporation = {}
        certificate_of_incorporation[:name] = "Certificate of Incorporation"
        certificate_of_incorporation[:options] = []
        certificate_of_incorporation[:options] << {
            identifier: "certificate_of_incorporation",
            name: "Certificate of Incorporation",
            uploaded: self.certificate_of_incorporation.present?
        }
        if self.kyc_documents.certificate_of_incorporation.present?
          file = {
              type: (self.kyc_documents.certificate_of_incorporation.first.doc_content_type),
              original: (self.kyc_documents.certificate_of_incorporation.first.doc.url),
              thumb: (self.kyc_documents.certificate_of_incorporation.first.doc.url(:thumb))
          }
          certificate_of_incorporation[:options][0][:file] = file
        end
        if self.system_messages.certificate_of_incorporation_messages.present?
          system_messages = self.system_messages.certificate_of_incorporation_messages
          certificate_of_incorporation[:options][0][:system_messages] = system_messages&.pluck(:content)
        end
        documents << certificate_of_incorporation

        # Document 2 - List of Partners with DIN
        list_of_partners_din = {}
        list_of_partners_din[:name] = "List of Partners with DIN"
        list_of_partners_din[:options] = []
        list_of_partners_din[:options] << {
            identifier: "list_of_partners_din",
            name: "List of Partners with DIN",
            uploaded: self.list_of_partners_din.present?
        }
        if self.kyc_documents.list_of_partners_din.present?
          file = {
              type: (self.kyc_documents.list_of_partners_din.first.doc_content_type),
              original: (self.kyc_documents.list_of_partners_din.first.doc.url),
              thumb: (self.kyc_documents.list_of_partners_din.first.doc.url(:thumb))
          }
          list_of_partners_din[:options][0][:file] = file
        end
        if self.system_messages.list_of_partners_din_messages.present?
          system_messages = self.system_messages.list_of_partners_din_messages
          list_of_partners_din[:options][0][:system_messages] = system_messages&.pluck(:content)
        end

        documents << list_of_partners_din

        # Document 3 - Supporting documents
        supporting_documents = {}
        supporting_documents[:name] = "Supporting Documents"
        supporting_documents[:options] = partnership_firm_supporting_documents

        documents << supporting_documents

      ## TRUST AND PARTNERSHIPS ##
      when CompanyType.id_for('Trust and Societies')
        # Document 1 - Trust Deed or Certificate of Registration
        trust_deed = {}
        trust_deed[:name] = "Trust Deed / Certificate of Registration"
        trust_deed[:options] = []
        trust_deed[:options] << {
            identifier: "trust_deed",
            name: "Trust Deed",
            uploaded: self.kyc_documents.trust_deed.present?
        }
        if self.kyc_documents.trust_deed.present?
          file = {
              type: (self.kyc_documents.trust_deed.first.doc_content_type),
              original: (self.kyc_documents.trust_deed.first.doc.url),
              thumb: (self.kyc_documents.trust_deed.first.url(:thumb))
          }
          trust_deed[:options][0][:file] = file
        end
        if self.system_messages.trust_deed_messages.present?
          system_messages = self.system_messages.trust_deed_messages
          trust_deed[:options][0][:system_messages] = system_messages&.pluck(:content)
        end

        trust_deed[:options] << {
            identifier: "certificate_of_registration",
            name: "Certificate of Registration",
            uploaded: self.kyc_documents.certificate_of_registration.present?
        }
        if self.kyc_documents.kyc_documents.certificate_of_registration.present?
          file = {
              type: (self.kyc_documents.certificate_of_registration.first.doc_content_type),
              original: (self.kyc_documents.certificate_of_registration.first.doc.url),
              thumb: (self.kyc_documents.certificate_of_registration.first.url(:thumb))
          }
          trust_deed[:options][1][:file] = file
        end
        if self.system_messages.certificate_of_registration_messages.present?
          system_messages = self.system_messages.certificate_of_registration_messages
          trust_deed[:options][1][:system_messages] = system_messages&.pluck(:content)
        end

        documents << trust_deed

        # Document 2 - List of Trustees / Office Bearers / Karta
        list_of_trustees_karta = {}
        list_of_trustees_karta[:name] = "List of Trustees / Office Bearers / Karta"
        list_of_trustees_karta[:options] = []
        list_of_trustees_karta[:options] << {
            identifier: "list_of_trustees_karta",
            name: "List of Trustees / Office Bearers / Karta",
            uploaded: self.list_of_trustees_karta.present?
        }
        if self.kyc_documents.list_of_trustees_karta.present?
          file = {
              type: (self.kyc_documents.list_of_trustees_karta.first.doc_content_type),
              original: (self.kyc_documents.list_of_trustees_karta.first.doc.url),
              thumb: (self.kyc_documents.list_of_trustees_karta.first.doc.url(:thumb))
          }
          list_of_trustees_karta[:options][0][:file] = file
        end
        if self.system_messages.list_of_trustees_karta_messages.present?
          system_messages = self.system_messages.list_of_trustees_karta_messages
          list_of_trustees_karta[:options][0][:system_messages] = system_messages&.pluck(:content)
        end

        documents << list_of_trustees_karta

        # Document 3 - Supporting documents
        supporting_documents = {}
        supporting_documents[:name] = "Supporting Documents"
        supporting_documents[:options] = partnership_firm_supporting_documents

        documents << supporting_documents

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

  def sole_proprietor_id_proof_documents
    options = []
    id_proof_options = ["Aadhar Card", "VAT Registration Certificate", "CST Registration Certificate", "Service Tax Registration Certificate", "Shops and Establishments Licence",
                                   "Ration Card", "Passport", "Voters ID Card"]
    id_proof_options.each do |option|
      option = {
          identifier: "id_proof",
          name: option,
          uploaded: self.kyc_documents.id_proof.first.present?
      }
      file = {}
      if self.kyc_documents.id_proof.present?
        file = {
            type: self.kyc_documents.id_proof.first.doc_content_type,
            original: self.kyc_documents.id_proof.first.doc.url,
            thumb: self.kyc_documents.id_proof.first.doc.url(:thumb)
        }
      end
      option[:file] = file
      if self.system_messages.id_proof_messages.present?
        option[:system_messages] = self.system_messages.id_proof_messages.pluck(:content)
      end
      options << option
    end

    options
  end

  def sole_proprietor_address_proof_documents
    options = []

    address_proof_options = ["Aadhar Card", "VAT Registration Certificate", "CST Registration Certificate", "Service Tax Registration Certificate", "Shops and Establishments Licence",
                             "Ration Card", "Passport", "Voters ID Card"]
    address_proof_options.each do |option|
      option = {
          identifier: "address_proof",
          name: option,
          uploaded: self.kyc_documents.address_proof.first.present?
      }
      file = {}
      if self.kyc_documents.address_proof.present?
        file = {
            type: self.kyc_documents.address_proof.first.doc_content_type,
            original: self.kyc_documents.address_proof.first.doc.url,
            thumb: self.kyc_documents.address_proof.first.doc.url(:thumb)
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
          uploaded: self.kyc_documents.supporting_document.first.present?
      }
      file = {}
      if self.kyc_documents.supporting_document.present?
        file = {
            type: self.kyc_documents.supporting_document.first.doc_content_type,
            original: self.kyc_documents.supporting_document.first.doc.url,
            thumb: self.kyc_documents.supporting_document.first.doc.url(:thumb)
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
