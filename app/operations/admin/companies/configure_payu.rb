class Admin::Companies::ConfigurePayu < Admin::Companies::Base

  attr_accessor :registered_mobile_number, :easy_account_number

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    id = params[:id] || params[:company_id]
    self.company = Company.find_by(id: id)
    # todo - change this after merge with company kyc
    self.registered_mobile_number = company.configuration.registered_mobile_number || company.company_kyc.registered_mobile_number
    self.easy_account_number = company.itz_cash_property.easy_account_no
  end

  def validate
    unless company.d_code.present?
      add_message :error, "This company does not have a D-code yet"
      return
    end

    unless registered_mobile_number.present?
      add_message :error, "Regisered mobile number not present"
      return
    end

    unless easy_account_number.present?
      add_message :error, "Easy account number not present yet"
    end
  end

  def process
    a = nil
    Open3.popen3("java GenericEncrypter #{easy_account_number} #{registered_mobile_number}") do |stdin, stdout, strerr|
      a = stdout.read
    end
    company.configuration.update(encrypted_easy_login_params: a)
  end

  def post_process
    add_message :success, "Account set up for PayU!"
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(user, params, messages)
  end
end