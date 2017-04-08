class AdminOperations::Company::Index < Company::Base

  attr_accessor :companies

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def authorize

  end

  def validate

  end

  def init
    self.companies = Company.all
  end

  def success
    AdminOperations::Company::Index::CompaniesPresenter.new(user, {companies: companies}, messages)
  end

  class AdminOperations::Company::Index::CompaniesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :companies

    has_scope :filter_search
    has_scope :created_between


    def init
      self.companies = apply_scopes(params[:companies], params)
    end
  end

end