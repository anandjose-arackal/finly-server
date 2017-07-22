class Admin::KycProcesses::Companies::Confirm < KycProcess::Company::Confirm

  attr_accessor :company, :company_kyc

  def user_model
    AdminUser
  end

  def pre_validate
    unless user.finly_admin?
      raise_unauthorized_exception
    end
    if user.blank? || params[:company_id].blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def validate
    super()
    # unless company_kyc.user_confirmed
    #   add_message :error, "User has not confirmed their documents yet"
    # end
  end

  def init
    id = params[:id] || params[:company_id]
    self.company = Company.find_by(id: id)
    self.company_kyc = company.company_kyc
  end

  def process
    unless company_kyc.update(kyc_status_id: KycStatus.id_for(:processing))
      add_message :error, company_kyc.errors.full_messages
    end
  end

  def post_process
    CompanyMailer.delay.send_to_itzcash(company)

    add_message :success, "Successfully sent the documents to ItzCash"
  end


end