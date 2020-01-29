class KycProcess::User::Show < KycProcess::User::Base

  def post_process
    # This will update the kyc status if card has been upgraded
    unless KycStatus.ids_for([:completed, :approved]).include? self.individual_kyc&.kyc_status_id
      self.individual_kyc.user.cards&.each do |card|
        ItzCash::AccountDetails.(individual_kyc.user, card: card)
      end
    end
  end

  def success
    params[:individual_kyc] = self.individual_kyc
    params[:kyc_operation_phone_number] = self.kyc_operation_phone_number
    KycProcess::User::Show::SuccessPresenter.new(user, params, messages)
  end

  class KycProcess::User::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :individual_kyc, :kyc_operation_phone_number

    def init
      self.individual_kyc = params[:individual_kyc]
      self.kyc_operation_phone_number = params[:kyc_operation_phone_number]
    end

  end

end