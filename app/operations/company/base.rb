class Company::Base < BaseOperation

  attr_accessor :company

  class Company::Base::CompanyPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :company

    def init
      self.company = params[:company]
    end

  end

end