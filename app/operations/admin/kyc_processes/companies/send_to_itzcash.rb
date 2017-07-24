class Admin::KycProcesses::Companies::SendToItzcash < Admin::KycProcesses::Companies::Base

  attr_accessor :company, :company_kyc

  def pre_validate
    super()
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters. Try again"
    end
  end

  def init
    id = params[:id] || params[:company_id]
    self.company = Company.find_by(id: id)
    self.company_kyc = company.company_kyc
  end

  def validate
    unless company_kyc.processing?
      add_message :error, "You need to confirm the documents before sending to ItzCash"
    end
  end

  def process
    # Trigger the mailer that sends the documents to ItzCash
    CompanyMailer.delay.send_to_itzcash(company)
  end

  def post_process
    add_message :success, "Sent mailer!"
  end
end