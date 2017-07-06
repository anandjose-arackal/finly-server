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
#

class CompanyKyc < ActiveRecord::Base
  include Attachable

  belongs_to :company
  belongs_to :kyc_status
  belongs_to :company_type
  has_many :system_messages, as: :messagable, dependent: :destroy

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

  def editable?
    [KycStatus.id_for(:incomplete), KycStatus.id_for(:submitted), KycStatus.id_for(:error)].include?(kyc_status_id)
  end

  def processing?
    if self.kyc_status_id == KycStatus.id_for(:processing)
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

  validate :pin_code_format

  private

  def pin_code_format
    if self.pin_code.present?
      unless self.pin_code =~ Constants::VALID_PIN_CODE
        errors.add(:pin_code, "is invalid")
      end
    end
  end

end
