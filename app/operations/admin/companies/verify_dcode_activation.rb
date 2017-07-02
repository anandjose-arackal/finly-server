class Admin::Companies::VerifyDcodeActivation < Admin::Companies::Base

  attr_accessor :company

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    id = params[:company_id] || params[:id]
    self.company = Company.find_by(id: id)
  end

  def validate
    unless company.d_code.present?
      add_message :error, "This company does not have a D Code yet!"
      return
    end
  end

  def process
    result = ItzCash::VirtualAccountBalance.(company)
    if result.success?
      # also save the respective easy account number if it's not saved already
      unless company.itz_cash_property.easy_account_no.present?
        ean = result.wallets[0][:account_number]
        company.itz_cash_property.update(easy_account_number: ean)
      end
      add_message :success, "D-Code successfully configured!"
    else
      add_message :error, "D-Code not configured yet"
    end
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(user, params, messages)
  end

end