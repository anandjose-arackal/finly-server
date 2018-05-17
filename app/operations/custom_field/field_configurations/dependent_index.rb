class CustomField::FieldConfigurations::DependentIndex < CustomField::FieldConfigurations::Base

  attr_accessor :drop_down_parent, :dependent_field_configurations

  class CustomField::FieldConfigurations::DependentIndex::FieldConfigurationPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :field_configurations

    def init
      self.field_configurations = params[:field_configurations]
    end

  end

  def init
    id = params[:id] || params[:drop_down_id]
    field_configurations = user.company.all_field_configurations
    self.drop_down_parent = FieldDropDownItem.with_field_configuration_id(field_configurations.pluck(:id)).find_by(id: id)
  end

  def validate
    if self.drop_down_parent.blank?
      add_message :error, "Drop down not found"
    end
  end

  def process
    # todo - for now only supporting single dependent custom fields, once multiple are supported,
    # the below variable will be an array by default
    self.dependent_field_configurations = self.drop_down_parent.dependent_field_configurations
  end

  def success
    params[:field_configurations] = self.dependent_field_configurations
    CustomField::FieldConfigurations::DependentIndex::FieldConfigurationPresenter.new(user, params, messages)
  end


end