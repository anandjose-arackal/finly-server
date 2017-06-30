class Agreements::Kyc::Update < Agreements::Base

  attr_accessor :company, :kyc_params, :kyc_config

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, please try again"
    end
  end

  def init
    self.company = user.company
    self.kyc_params = company_kyc_params
    # every company will have an individual KYC configuration
    self.kyc_config = company.company_kyc
  end

  def validate
    # check whether the user is the POC for that company
    unless user.point_of_contact
      add_message :error, "You are not authorized to upload this information"
    end
  end

  def process
    unless kyc_config.update(kyc_params)
      add_message :error, kyc_config.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Data saved!"
  end

  private

  def company_kyc_params
    params.require(:company_kyc).permit(:company_type_id, :registered_mobile_number, :date_of_establishment, :street_2, :street_3, :pin_code)
  end
end