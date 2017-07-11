class KycProcess::Company::Retract < KycProcess::Company::Base

  attr_accessor :company, :company_kyc

  def pre_validate
    if user.blank?
      add_message :error, "Invalid request, try again"
    end
  end

  def init
    self.company = user.company
    self.company_kyc = company&.company_kyc
  end

  def validate
    if company_kyc.blank?
      add_message :error, "Company documents not found"
      return
    end

    unless company_kyc.processing?
      add_message :error, "You cannot retract the documents at this stage"
    end
  end

  def process
    # updates the status of the kyc from submitted to processing
    unless company_kyc.update(kyc_status_id: KycStatus.id_for(:submitted))
      add_message :error, company_kyc.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Successfully confirmed submission of documents"
  end
end