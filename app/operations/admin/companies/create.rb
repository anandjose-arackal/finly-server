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
    # company_create_params.permit!
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