class KycProcess::Company::Show < KycProcess::Company::Base

  def process

  end

  # def validate
  #   unless user.point_of_contact
  #     raise_unauthorized_exception
  #   end
  # end

  def success
    params[:company_kyc] =  self.company_kyc
    KycProcess::Company::Show::DocumentsPresenter.new(user, params, messages)
  end

  class KycProcess::Company::Show::DocumentsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :company_kyc, :user_completed, :actions

    def init
      self.company_kyc = params[:company_kyc]
      self.user_completed = company_kyc.processing?
      self.actions = retrieve_actions
    end

    def retrieve_actions
      actions = {}
      if company_kyc.kyc_status_id == KycStatus.id_for(:incomplete)
        actions[:upload] = Rails.application.routes.url_helpers.kyc_docs_update_path
      elsif company_kyc.kyc_status_id == KycStatus.id_for(:submitted)
        actions[:upload] = Rails.application.routes.url_helpers.kyc_docs_update_path
        actions[:confirm] = Rails.application.routes.url_helpers.kyc_confirm_path
        # because the admin panel operation inherits this one, and this needs to be shown only if the particular user is a Finly Admin
        if user.finly_admin?
          actions[:reject] = Rails.application.routes.url_helpers.admin_users_kyc_company_reject_path(company_kyc.company)
        end
      elsif company_kyc.kyc_status_id == KycStatus.id_for(:submitted)
        actions[:unconfirm] = ""
      end
      actions
    end

    def documents
      docs = []
      # pan card is common for all
      id_proof = {}
      id_proof[:name] = "ID Proof"
      file = {}
      if company_kyc.pan_card.present?
        file = {
          type: company_kyc.pan_card_content_type,
          original: company_kyc.pan_card&.url,
          thumb: company_kyc.pan_card&.url(:thumb)
        }
      end
      system_messages = nil
      if company_kyc.system_messages.pan_card_messages.present?
        system_messages = company_kyc.system_messages.pan_card_messages
      end
      id_proof[:options] = []
      id_proof[:options] << {
         identifier: "pan_card",
         name: "PAN",
         uploaded: company_kyc.pan_card.present?,
         file: file,
         system_messages: system_messages&.pluck(:content)
      }
      docs << id_proof

      # now based on company type, the other document is decided
      case company_kyc.company_type_id
        when 1
          # sole proprietor
          address_proof = {}
          address_proof[:name] = "Address Proof"
          address_proof[:options] = []
          address_proof[:options] << {
              identifier: "aadhar_card",
              name: "Aadhar Card",
              uploaded: company_kyc.aadhar_card.present?
          }
          address_proof[:options] << {
              identifier: "vat_registration_certificate",
              name: "VAT registration certificate",
              uploaded: company_kyc.vat_registration_certificate.present?
          }
          if company_kyc.aadhar_card.present?
            file = {
                type: (company_kyc.aadhar_card_content_type),
                original: (company_kyc.aadhar_card&.url),
                thumb: (company_kyc.aadhar_card&.url(:thumb))
            }
            address_proof[:options][0][:file] = file
          end
          if company_kyc.system_messages.aadhar_card_messages.present?
            system_messages = company_kyc.system_messages.aadhar_card_messages
            address_proof[:options][0][:system_messages] = system_messages&.pluck(:content)
          end
          if company_kyc.vat_registration_certificate.present?
            file = {
                type: (company_kyc.vat_registration_certificate_content_type),
                original: (company_kyc.vat_registration_certificate&.url),
                thumb: (company_kyc.vat_registration_certificate&.url(:thumb))
            }
            address_proof[:options][1][:file] = file
          end
          if company_kyc.system_messages.vat_registration_certificate_messages.present?
            system_messages = company_kyc.system_messages.vat_registration_certificate_messages
            address_proof[:options][1][:system_messages] = system_messages&.pluck(:content)
          end
          docs << address_proof
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
      return docs
    end

  end

end