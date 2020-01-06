class Admin::Implementations::Index < Admin::Base

  attr_accessor :implementation_requests, :company, :policies

  def pre_validate
    if user.blank? || params.blank? || params[:request_key].blank? || params[:company_id].blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    self.company = Company.find_by id: params[:company_id]
  end

  def process
    self.implementation_requests = company.admin_implementation_requests.where('request_key LIKE ?',"%#{params[:request_key]}%")
    self.policies = company.policies if ['lrms', 'lurms', 'approval_flow'].include?(params[:request_key])
  end

  def success
    params[:implementation_requests] = implementation_requests
    params[:policies] = policies
    Admin::Implementations::Index::ImplementataionPresenter.new(user, params, messages)
  end

  class Admin::Implementations::Index::ImplementataionPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :implementation_requests, :paginated_requests,:policies,:count

    def init
      per_page = params[:per_page] || 30
      self.implementation_requests = params[:implementation_requests]
      self.paginated_requests = implementation_requests.paginate(page: params[:page], per_page: params[:per_page])
      self.policies = params[:policies]
      self.count = implementation_requests.count
    end
  end

end
