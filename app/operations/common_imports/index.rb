class CommonImports::Index < CommonImports::Base

  attr_accessor :common_import_requests, :company, :policies

  def pre_validate
    if user.blank? || params.blank? || params[:request_key].blank? || params[:company_id].blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    self.company = Company.find_by id: params[:company_id]
  end

  def process
    self.common_import_requests = company.common_import_requests.where('request_key LIKE ?',"%#{params[:request_key]}%")
    self.policies = company.policies if ['lrms', 'lurms', 'approval_flow'].include?(params[:request_key])
  end

  def success
    params[:common_import_requests] = common_import_requests
    params[:policies] = policies
    CommonImports::Index::ImplementataionPresenter.new(user, params, messages)
  end

  class CommonImports::Index::ImplementataionPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :common_import_requests, :paginated_requests,:policies,:count

    def init
      per_page = params[:per_page] || 30
      self.common_import_requests = params[:common_import_requests]
      self.paginated_requests = common_import_requests.paginate(page: params[:page], per_page: params[:per_page])
      self.policies = params[:policies]
      self.count = common_import_requests.count
    end
  end

end
