class Admin::Company::Create < Admin::Company::Base

  attr_accessor :company

  def pre_validate
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
    # send mailer perhaps?

    add_message :success, "Company created!"
  end


end