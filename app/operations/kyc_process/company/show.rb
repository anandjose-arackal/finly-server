class KycProcess::Company::Show < KycProcess::Company::Base

  def process

  end

  def validate
    unless user.point_of_contact
      raise_unauthorized_exception
    end
  end

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
      pan_card = {}
      pan_card[:name] = "PAN Card"
      pan_card[:identifier] = "pan_card"
      pan_card[:uploaded] = company_kyc.pan_card.present?
      if company_kyc.pan_card.present?
        pan_card[:file] = {
            type: company_kyc.pan_card_content_type,
            original: company_kyc.pan_card&.url,
            thumb: company_kyc.pan_card&.url(:thumb)
        }
      end
      docs << pan_card

      # now based on company type, the other document is decided
      case company_kyc.company_type_id
        when 1
          # sole proprietor -
          aadhar = {}
          aadhar[:name] = "Aadhar Card"
          aadhar[:identifier] = "aadhar_card"
          aadhar[:uploaded] = company_kyc.aadhar_card.present? || company_kyc.certificate_of_registration.present?
          aadhar[:options] = []
          if company_kyc.aadhar_card.present?
            aadhar[:options] << {
                name: "Aadhar Card",
                identifier: "aadhar_card",
                uploaded: company_kyc.aadhar_card.present?,
            }
          end
          if company_kyc.vat_registration_certificate.present?
            aadhar[:options] << {
                name: "VAT registration certificate",
                identifier: "vat_registration_certificate",
                uploaded: company_kyc.vat_registration_certificate.present?,
            }
          end
          if aadhar[:uploaded]
            aadhar[:file] = {
                type: (company_kyc.aadhar_card&.content_type || company_kyc.vat_registration_certificate&.content_type),
                original: (company_kyc.aadhar_card&.url || company_kyc.vat_registration_certificate&.url),
                thumb: (company_kyc.aadhar_card&.url(:thumb) || company_kyc.vat_registration_certificate&.url(:thumb))
            }
          end
          docs << aadhar
        when 3, 5, 6
          coi = {}
          coi[:name] = "Certificate of Incorporation"
          coi[:identifier] = "coi"
          coi[:uploaded] = company_kyc.coi.present?
          if company_kyc.coi.present?
            coi[:file] = {
                type: company_kyc.coi_content_type,
                original: company_kyc.coi&.url,
                thumb: company_kyc.coi&.url(:thumb)
            }
          end
          docs << coi
        when 2, 4
          certificate_of_registration = {}
          certificate_of_registration[:name] = "Certificate of Regiration"
          certificate_of_registration[:identifier] = "certificate_of_registration"
          certificate_of_registration[:uploaded] = company_kyc.certificate_of_registration.present?
          if company_kyc.certificate_of_registration.present?
            certificate_of_registration[:file] = {
                type: company_kyc.certificate_of_registration_content_type,
                original: company_kyc.certificate_of_registration&.url,
                thumb: company_kyc.certificate_of_registration&.url(:thumb)
            }
          end
          docs << coi
        # when 4
          # need to be clarified
      end
      return docs
    end

  end

end