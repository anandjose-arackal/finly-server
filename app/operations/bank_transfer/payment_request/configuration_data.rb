class BankTransfer::PaymentRequest::ConfigurationData < BankTransfer::PaymentRequest::Base

  def init
    params[:departments] = Company::Departments::Index.(current_user, params)
    params[:categories] = Categories::Index.(current_user, params)
    params[:policies] = Policy::VendorPayments::Index.(current_user, params)
    params[:cost_centers] = CostCenters::Index.(current_user, params)
    params[:tds_slabs] = TdsSlabs::Index.(current_user, params)

  end

  # def authorize

  # end

  # def process
    
  # end

  def success
    # params[:departments] = self.departments
    # params[:categories] = self.categories
    # params[:policies] = self.policies
    # params[:cost_centers] = self.cost_centers
    BankTransfer::PaymentRequest::ConfigurationDataPresenter.new(user, params, messages)
  end

  class BankTransfer::PaymentRequest::ConfigurationDataPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :departments, :cost_centers, :categories, :policies, :tds_slabs
    
    def init
      self.departments = params[:departments]
      self.categories = params[:categories]
      self.policies = params[:policies]
      self.cost_centers = params[:cost_centers]
      self.tds_slabs = params[:tds_slabs]

    end

  end

end

