class Admin::Companies::Create < Admin::Companies::Base

  attr_accessor :company, :company_create_params

  def pre_validate
    super()
    if user.blank? || params.blank?
      add_message :error, "Invalid paramsters, try again"
    end
  end

  def init
    self.company_create_params = company_params
  end

  def validate

  end

  def pre_process
    # self.company_create_params[:company_kyc_attributes] = params[:company_kyc_attributes]
    # self.company_create_params[:company_kyc_attributes] = {} if company_create_params[:company_kyc_attributes].nil?
    self.company_create_params[:company_create_attribute][:kyc_status_id] = KycStatus.id_for(:incomplete)
    company_create_params.permit!
  end

  def process
    self.company = Company.new(company_create_params)
    unless company.save
      add_message :error, company.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Company created!"
  end

end