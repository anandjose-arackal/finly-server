class KycProcess::Company::Show < KycProcess::Company::Base

  def process

  end

  def success
    params[:company_kyc] =  self.company_kyc
    KycProcess::Company::Show::SuccessPresenter.new(user, params, messages)
  end

  class KycProcess::Company::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :company_kyc, :user_completed

    def init
      self.company_kyc = params[:company_kyc]
      self.user_completed = company_kyc.processing?
    end

    def documents
      docs = []
      # pan card is common for all
      pan_card = {}
      pan_card[:name] = "PAN Card"
      pan_card[:identifier] = "pan"
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
          # sole proprietor
          aadhar = {}
          aadhar[:name] = "Aadhar Card"
          aadhar[:identifier] = "aadhar"
          aadhar[:uploaded] = company_kyc.aadhar_card.present? || company_kyc.certificate_of_registration.present?
          aadhar[:options] = ["Aadhar Card", "Certificate of Registration"]
          if company_kyc.aadhar_card.present?
            aadhar[:file] = {
                type: company_kyc.aadhar_card.content_type,
                file: company_kyc.aadhar_card&.url,
                thumb: company_kyc.aadhar_card&.url(:thumb)
            }
          elsif company_kyc.certificate_of_registration.present?
            aadhar[:file] = {
                type: company_kyc.certificate_of_registration&.content_type,
                file: company_kyc.certificate_of_registration&.url,
                thumb: company_kyc.certificate_of_registration&.url(:thumb)
            }
          end
          docs << aadhar
        when 2, 3, 5
          coi = {}
          coi[:name] = "Certificate of Incorporation"
          coi[:identifier] = "coi"
          coi[:uploaded] = company_kyc.coi.present?
          if company_kyc.coi.present?
            coi[:file] = {
                type: company_kyc.coi_content_type,
                file: company_kyc.coi&.url,
                thumb: company_kyc.coi&.url(:thumb)
            }
          end
          docs << coi
        when 4
          # need to be clarified
      end
      return docs
    end

  end

end