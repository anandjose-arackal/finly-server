class Admin::Companies::Create < Admin::Companies::Base

  attr_accessor :company

  def pre_validate
    super()
    if user.blank? || params.blank?
      add_message :error, "Invalid paramsters, try again"
    end
  end

  def init

  end

  def validate

  end

  def process
    self.company = Company.new(company_params)
    unless company.save
      add_message :error, company.errors.full_messages
    end
  end

  def post_process
    if company.company_kyc.present?
      company.company_kyc.update(company_type_id: 3)
    end
    add_message :success, "Company created!"
  end

end