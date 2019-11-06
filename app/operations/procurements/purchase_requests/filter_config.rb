class Procurements::PurchaseRequests::FilterConfig < Procurements::PurchaseRequests::Base
  attr_accessor :policies, :custom_field_configurations

  def init
    self.policies = Policy::VendorPayments::Index.(user, params).policies
  end

  def validate
  end

  def process
    custom_field_op = CustomField::Configuration::Index.(user, custom_field_filter_params )
    self.custom_field_configurations = custom_field_op.field_configurations
  end

  def success
    params[:policies] = self.policies
    params[:custom_field_configurations] = self.custom_field_configurations
    Procurements::PurchaseRequests::FilterConfig::ConfigPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseRequests::FilterConfig::ConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :locations, :departments, :cost_centers, :policies, :custom_field_configurations

    def init
      self.policies = params[:policies]

      config_op = ::Configs::LocDept.(user, params)

      self.locations = config_op.locations
      self.departments = config_op.departments
      self.cost_centers = config_op.cost_centers
      self.custom_field_configurations = params[:custom_field_configurations]
    end
  end


  private

  def custom_field_filter_params
    {
      filter_field_type_id: [FieldType.id_for(:drop_down), FieldType.id_for(:multiselect), FieldType.id_for(:text)],
      filter_parent_type_id: [FieldParentType.id_for(:purchase_request)]
    }    

  end
end