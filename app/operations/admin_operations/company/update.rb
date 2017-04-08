class AdminOperations::Company::Update < AdminOperations::Company::Base

  attr_accessor :company

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    self.company = Company.find_by(id: params[:id])
  end

  def validate
    if company.blank?
      add_message :error, "Company not found"
    end
  end

  def process
    unless company.update(company_params)
      add_message :error, company.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Company updated"
  end


end