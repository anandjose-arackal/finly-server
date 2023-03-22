# Fixme: Legacy code
class Dashboard::P2P::FilterConfigs < Dashboard::VendorPayments::Base
  attr_accessor :departments, :sub_departments, :request_types, :policies, :locations

  def init
    self.departments = Company::Departments::Index.(user, params).policy_department_filter_mapping
    self.policies = Policy::VendorPayments::Index.(user, params).policies
    self.locations = Company::Locations::Index.(user, params).policy_location_filter_mapping
  end

  def success
    params[:departments] = self.departments
    params[:policies] = self.policies
    params[:locations] = self.locations
    Dashboard::P2P::FilterConfigs::Presenter.new(user, params, messages)
  end

  class Dashboard::P2P::FilterConfigs::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :departments, :sub_departments, :request_types, :policies, :locations

    has_scope :filter_status_id
    has_scope :filter_user_id
    has_scope :filter_only_roots

    def init
      self.departments = apply_scopes(params[:departments], {filter_only_roots: true})
      self.sub_departments = params[:departments].only_sub_departments rescue Department.none
      self.policies = params[:policies]
      self.locations = params[:locations]
      self.policies = params[:policies]
      self.locations = params[:locations]
    end
  end
end