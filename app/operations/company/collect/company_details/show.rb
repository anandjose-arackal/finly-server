class Company::Collect::CompanyDetails::Show < Company::Base

  attr_accessor :collect_detail, :locations

  class Company::Collect::CompanyDetails::Show::DetailPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :collect_detail, :locations

    def init
      self.collect_detail = params[:collect_detail]
      self.locations = params[:locations]
    end

  end

  def init
    self.collect_detail = user.company.collect_company_detail
    self.locations = user.company.locations
  end

  def validate
    if self.collect_detail.blank?
      add_message :error, "Company detail not found"
      return
    end
  end

  def success
    params[:collect_detail] = self.collect_detail
    params[:locations] = self.locations
    Company::Collect::CompanyDetails::Show::DetailPresenter.new(user, params, messages)
  end

end