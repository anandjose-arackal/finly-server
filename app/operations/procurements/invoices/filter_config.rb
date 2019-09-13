class Procurements::Invoices::FilterConfig < Procurements::Invoices::Base
  attr_accessor :locations, :departments, :cost_centers, :policies, :custom_fields_config

  def init
    self.policies = ::Policy::VendorPayments::Index.(user, params).policies rescue Policy.none

    self.departments = Company::Departments::Index.(user, params).policy_department_filter_mapping
    # self.locations = Company::Locations::Index.(user, params).locations
    self.locations = Company::Locations::Index.(user, params).policy_location_filter_mapping
    self.cost_centers = CostCenters::Index.(user, params).cost_centers
    load_custom_fields_config
    params[:custom_fields_config] = self.custom_fields_config
  end

  def success
    params[:locations] = self.locations
    params[:departments] = self.departments
    params[:cost_centers] = self.cost_centers
    params[:policies] = self.policies
    Procurements::Invoices::FilterConfig::ConfigPresenter.new(user, params, messages)
  end

  class Procurements::Invoices::FilterConfig::ConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :locations, :departments, :cost_centers, :policies, :custom_fields_config

    def init
      self.locations = params[:locations]
      self.departments = params[:departments]
      self.cost_centers = params[:cost_centers]
      self.policies = params[:policies]
      self.custom_fields_config = params[:custom_fields_config]
    end
  end

  def load_custom_fields_config
    configurations = user.company.field_configurations.exclude_deleted.root_fields.order_created_at_desc
    self.custom_fields_config = {}
    self.custom_fields_config[:invoice] = configurations.with_parent_type(FieldParentType.id_for(:invoice))
  end
end