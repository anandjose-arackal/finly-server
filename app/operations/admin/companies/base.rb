class Admin::Companies::Base < BaseOperation

  def company_params
    params.require(:company).permit(:name, itz_cash_property_attributes: [:d_code])
  end

  def success
    Admin::Companies::Base::CompanyPresenter.new(user, {company: company}, messages)
  end


  class Admin::Companies::Base::CompanyPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :company

    def init
      self.company = params[:company]
    end
  end
end