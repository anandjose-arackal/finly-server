class KycProcess::Company::Update < KycProcess::Company::Base
  attr_accessor :kyc_params

  def init
    super
    self.kyc_params = kyc_strong_params
  end

  def validate
    # depending on the type of company, we will be checking the documents that are uploded
  end

  def pre_process
    # self.kyc_params[:aadhar_card] = kyc_params[:aadhar]
    # self.kyc_params[:pan_card] = kyc_params[:pan_card]
    # kyc_params.permit!
  end

  def process
    unless self.company_kyc.update(self.kyc_params)
      add_message :error, self.company_kyc.errors.full_messages
    end
  end

  def post_process
    # update the status based on the company type and documents uploaded
    case company_kyc.company_type_id
      when 1
        if company_kyc.pan_card.present? && (company_kyc.aadhar_card.present? || company_kyc.driving_licence.present? || company_kyc.passport.present?)
          company_kyc.update(kyc_status_id: KycStatus.id_for(:submitted))
        else
          company_kyc.update(kyc_status_id: KycStatus.id_for(:incomplete))
        end
      when 3, 5
        if company_kyc.pan_card.present? && company_kyc.coi.present?
          company_kyc.update(kyc_status_id: KycStatus.id_for(:submitted))
        else
          company_kyc.update(kyc_status_id: KycStatus.id_for(:incomplete))
        end
      when 2
        if company_kyc.pan_card.present? && company_kyc.certificate_of_registration.present?
          company_kyc.update(kyc_status_id: KycStatus.id_for(:submitted))
        else
          company_kyc.update(kyc_status_id: KycStatus.id_for(:incomplete))
        end
    end

    add_message :success, "Documents uploaded successfully"

    # if self.company_kyc.coi.present? and self.company_kyc.pan_card.present?
    #   self.company_kyc.update(kyc_status_id: KycStatus.id_for(:processing))
    # else
    #   self.company_kyc.update(kyc_status_id: KycStatus.id_for(:incomplete))
    # end
  end

  def success
    params[:processing] = company.company_kyc.processing?
    KycProcess::Company::Update::KycPresenter.new(user, params, messages)
  end

  class KycProcess::Company::Update::KycPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :completed

    def init
      # because completed from the user's perspective the process (uploading) is completed
      self.completed = params[:processing]
    end
  end

  protected

  def kyc_strong_params
    params.require(:company_kyc).permit(:coi, :pan_card, :passport, :driving_licence, :aadhar_card, :vat_registration_certificate, :registration_of_trust)
  end

end