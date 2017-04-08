class AdminOperations::Company::Index < Company::Base


  class AdminOperations::Company::Index::CompaniesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :companies

    has_scope :filter_search
    has_scope :created_at


    def init
      self.companies = apply_scopes(params[:companies], params)
    end
  end

end