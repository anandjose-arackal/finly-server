class Procurements::Invoices::FilterConfig < Procurements::Invoices::Base
  attr_accessor :locations, :departments, :cost_centers, :policies, :custom_fields_config

  def init
    self.policies = ::Policy::VendorPayments::Index.(user, params).policies rescue Policy.none

    self.departments = Company::Departments::Index.(user, params).policy_department_filter_mapping
    # self.locations = Company::Locations::Index.(user, params).locations
    self.locations = Company::Locations::Index.(user, params).policy_location_filter_mapping
    self.cost_centers = CostCenters::Index.(user, params).cost_centers
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

    attr_accessor :locations, :departments, :cost_centers, :policies, :custom_fields_config, :agreement_invoice_enabled, :invoice_custom_field_configurations

    def init
      self.locations = params[:locations]
      self.departments = params[:departments]
      self.cost_centers = params[:cost_centers]
      self.policies = params[:policies]
      self.custom_fields_config = params[:custom_fields_config]
      self.agreement_invoice_enabled = user.company.agreement_based_payment_system_enabled?
      invoice_custom_field_op = CustomField::Configuration::Index.(user, invoice_custom_field_filter_params )
      self.invoice_custom_field_configurations = invoice_custom_field_op.field_configurations

    end

    def invoice_custom_field_filter_params
      {
        filter_field_type_id: [FieldType.id_for(:drop_down), FieldType.id_for(:multiselect), FieldType.id_for(:text)],
        filter_parent_type_id: [FieldParentType.id_for(:invoice)]
      }    

    end
  end


end