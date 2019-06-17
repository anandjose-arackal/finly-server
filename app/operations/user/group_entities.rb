class User::GroupEntities < User::Base

  attr_accessor :companies, :email, :mobile_number

  class User::GroupEntities::CompaniesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :companies

    def init
      self.companies = params[:companies]
    end

  end

  def init
    self.email = user.email
    self.mobile_number = user.mobile_number
  end

  def validate

  end

  def process
    users = User.with_email_or_mobile_number(self.email, self.mobile_number)
    self.companies = Company.with_id(users.pluck(:company_id))
  end

  def success
    params[:companies] = self.companies
    User::GroupEntities::CompaniesPresenter.new(user, params, messages)
  end
end