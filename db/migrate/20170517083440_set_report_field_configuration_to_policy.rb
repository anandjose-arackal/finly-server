class SetReportFieldConfigurationToPolicy < ActiveRecord::Migration
  def change
    FieldConfiguration.unscoped.where(configurable_type: 'Company', field_parent_type_id: [FieldParentType.id_for(:report), FieldParentType.id_for(:money_request)]).each do |config|
      default_policy = Company.find_by(id: config.configurable_id).default_policy
      config.update(configurable_type: 'Policy', configurable_id: default_policy.id)
    end
  end
end
