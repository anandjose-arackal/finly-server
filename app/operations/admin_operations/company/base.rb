class AdmnOperations::Company::Base < BaseOperations

  def company_attributes
    params.require(:company).permit(:name, itz_cash_property_attributes: [:d_code])
  end

  class AdminOperations::Company::Base::CompanyPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :company

    def init
      self.company = params[:company]
    end
  end
end