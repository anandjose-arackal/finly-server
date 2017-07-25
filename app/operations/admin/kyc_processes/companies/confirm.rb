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
    # check if the user's agreements have been uploaded yet
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
    if company.accepted_agreements?
      # add a track to say that it has been sent to ItzCash
      trail = company_kyc.company_kyc_trails.build(action_resource: user, action_id: CompanyKycTrailAction.id_for(:sent_to_itzcash)).save
      CompanyMailer.delay.send_to_itzcash(company)
    end

    add_message :success, "Successfully sent the documents to ItzCash"
  end


end