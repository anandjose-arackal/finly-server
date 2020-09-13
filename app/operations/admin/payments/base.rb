class Admin::Payments::Base < Admin::Base  

  class Admin::Payments::Base::PaymentPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :status, :payment

    def init
      self.status = params[:status]
      self.payment = params[:payment]
    end

  end
end
