class KycProcess::Company::Show < KycProcess::Company::Base

  def success
    params[:company_kyc] =  self.company_kyc
    KycProcess::Company::Show::SuccessPresenter.new(user, params, messages)
  end

  class KycProcess::Company::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :company_kyc

    def init
      self.company_kyc = params[:company_kyc]
    end

  end

end