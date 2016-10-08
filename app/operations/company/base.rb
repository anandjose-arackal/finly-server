class Company::Base < BaseOperation

  class Company::Base::CompanyPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :company

    def init
      self.company = params[:company]
    end

  end

end