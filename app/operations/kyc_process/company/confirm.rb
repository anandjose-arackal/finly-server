class KycProcess::Company::Confirm < KycProcess::Company::Base

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
      add_message :error, "Company not found"
    end
  end

  def process
    # updates the status of the kyc from submitted to processing
    unless company_kyc.update(kyc_status_id: KycStatus.id_for(:processing))
      add_message :error, company_kyc.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Successfully confirmed submission of documents"
  end
end