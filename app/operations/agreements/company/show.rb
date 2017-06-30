class Agreements::Company::Show < Agreements::Base

  attr_accessor :company

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, please try again"
    end
  end

  def init
    self.company = user.company
  end

  def validate

  end

  def authorize
    unless user.point_of_contact
      raise_unauthorized_exception
    end
  end

  def process

  end

  def post_process

  end

  def success
    params[:company_kyc] = company.company_kyc
    params[:company] = company
    Agreements::Company::Show::CompanyKycPresenter.new(user, params, messages)
  end

  class Agreements::Company::Show::CompanyKycPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :email, :registered_mobile_number, :poc_first_name, :poc_last_name, :company,
                  :company_type, :street_2, :street_3, :date_of_establishment, :pin_code, :company_kyc

    def init
      self.company = params[:company]
      self.company_kyc = params[:company_kyc]
      self.email = user.email
      self.poc_first_name = user.first_name
      self.poc_last_name = user.last_name
      self.registered_mobile_number = user.mobile_number
      self.company_type = company_kyc&.company_type
      self.street_2 = company_kyc&.street_2
      self.street_3 = company_kyc&.street_3
      self.pin_code = company_kyc&.pin_code
      self.date_of_establishment = company_kyc&.date_of_establishment
    end
  end
end