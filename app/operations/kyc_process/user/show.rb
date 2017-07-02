class KycProcess::User::Show < KycProcess::User::Base

  def success
    params[:individual_kyc] =  self.individual_kyc
    KycProcess::User::Show::SuccessPresenter.new(user, params, messages)
  end

  class KycProcess::User::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :individual_kyc

    def init
      self.individual_kyc = params[:individual_kyc]
    end

  end

end