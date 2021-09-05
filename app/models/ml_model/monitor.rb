# == Schema Information
#
# Table name: ml_models
#
#  id              :bigint           not null, primary key
#  company_id      :integer          not null
#  type            :string(255)      not null
#  config          :text(4294967295)
#  built_at        :datetime
#  build_schedule  :string(255)
#  track_schedule  :string(255)
#  build_duration  :integer
#  tracked_at      :datetime
#  algorithm       :string(255)
#  target_key      :string(255)      not null
#  target_key_type :string(255)      not null
#  split_key       :string(255)
#  split_key_type  :string(255)
#  model_klass     :string(255)
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  form_id         :string(255)
#  parent_id       :string(255)
#  parent_type     :string(255)
#  pivot_keys      :string(255)
#
class MlModel::Monitor < MlModel

  config :fields

  schema_validation do
    required(:config).hash do
      required(:fields).array do
        hash do
          required(:name).filled
          required(:type).filled(included_in?: FIELD_TYPES.values)
          optional(:value).filled
        end
      end
    end
  end

  def self.seed_data
    prediction_enabled_company_ids = FeatureSubscription.where(predictions_enabled: true).pluck(:company_id)
    Company.where(id: prediction_enabled_company_ids).find_each do |company|
       [{"config"=>{"fields"=>[{"name"=>"created_by_id", "type"=>"category", "value"=>"{{record.created_by_id}}"}, {"name"=>"vendor_id", "type"=>"category"}]}, "build_schedule"=>"weekly", "track_schedule"=>nil, "algorithm"=>"naive_bayes", "target_key"=>"policy_id", "target_key_type"=>"category", "split_key"=>"submitted_at", "split_key_type"=>"datetime", "model_klass"=>"Invoice", "pivot_keys": ["vendor_id"]}, 
       {"config"=>{"fields"=>[{"name"=>"created_by_id", "type"=>"category", "value"=>"{{record.created_by_id}}"}, {"name"=>"policy_id", "type"=>"category"}, {"name"=>"vendor_id", "type"=>"category"}]}, "build_schedule"=>"weekly", "track_schedule"=>nil, "algorithm"=>"naive_bayes", "target_key"=>"department_id", "target_key_type"=>"category", "split_key"=>"submitted_at", "split_key_type"=>"datetime", "model_klass"=>"Invoice", "pivot_keys": ["vendor_id"]}, 
       {"config"=>{"fields"=>[{"name"=>"created_by_id", "type"=>"category", "value"=>"{{record.created_by_id}}"}, {"name"=>"policy_id", "type"=>"category"}, {"name"=>"cost_center_id", "type"=>"category"}]}, "build_schedule"=>"weekly", "track_schedule"=>nil, "algorithm"=>"naive_bayes", "target_key"=>"cost_center_id", "target_key_type"=>"category", "split_key"=>"submitted_at", "split_key_type"=>"datetime", "model_klass"=>"Invoice", "pivot_keys": ["vendor_id"]}, 
       {"config"=>{"fields"=>[{"name"=>"created_by_id", "type"=>"category", "value"=>"{{record.created_by_id}}"}, {"name"=>"policy_id", "type"=>"category"}, {"name"=>"vendor_id", "type"=>"category"}, {"name"=>"department_id", "type"=>"category"}, {"name"=>"cost_center_id", "type"=>"category"}]}, "build_schedule"=>"weekly", "track_schedule"=>nil, "algorithm"=>"naive_bayes", "target_key"=>"location_id", "target_key_type"=>"category", "split_key"=>"submitted_at", "split_key_type"=>"datetime", "model_klass"=>"Invoice", "pivot_keys": ["vendor_id"]}, 
       {"config"=>{"fields"=>[{"name"=>"created_by_id", "type"=>"category", "value"=>"{{record.created_by_id}}"}, {"name"=>"policy_id", "type"=>"category"}, {"name"=>"vendor_id", "type"=>"category"}, {"name"=>"department_id", "type"=>"category"}, {"name"=>"cost_center_id", "type"=>"category"}]}, "build_schedule"=>"weekly", "track_schedule"=>nil, "algorithm"=>"naive_bayes", "target_key"=>"delivery_location_id", "target_key_type"=>"category", "split_key"=>"submitted_at", "split_key_type"=>"datetime", "model_klass"=>"Invoice", "pivot_keys": ["vendor_id"]}, 
       {"config"=>{"fields"=>[{"name"=>"created_by_id", "type"=>"category", "value"=>"{{record.created_by_id}}"}]}, "build_schedule"=>"weekly", "track_schedule"=>nil, "algorithm"=>"naive_bayes", "target_key"=>"policy_id", "target_key_type"=>"category", "split_key"=>"submitted_at", "split_key_type"=>"datetime", "model_klass"=>"PurchaseRequest", "pivot_keys": ["created_by_id"]}, 
       {"config"=>{"fields"=>[{"name"=>"created_by_id", "type"=>"category", "value"=>"{{record.created_by_id}}"}, {"name"=>"policy_id", "type"=>"category"}]}, "build_schedule"=>"weekly", "track_schedule"=>nil, "algorithm"=>"naive_bayes", "target_key"=>"department_id", "target_key_type"=>"category", "split_key"=>"submitted_at", "split_key_type"=>"datetime", "model_klass"=>"PurchaseRequest", "pivot_keys": ["created_by_id"]}, 
       {"config"=>{"fields"=>[{"name"=>"created_by_id", "type"=>"category", "value"=>"{{record.created_by_id}}"}, {"name"=>"policy_id", "type"=>"category"}]}, "build_schedule"=>"weekly", "track_schedule"=>nil, "algorithm"=>"naive_bayes", "target_key"=>"cost_center_id", "target_key_type"=>"category", "split_key"=>"submitted_at", "split_key_type"=>"datetime", "model_klass"=>"PurchaseRequest", "pivot_keys": ["created_by_id"]}, 
       {"config"=>{"fields"=>[{"name"=>"created_by_id", "type"=>"category", "value"=>"{{record.created_by_id}}"}, {"name"=>"policy_id", "type"=>"category"}, {"name"=>"department_id", "type"=>"category"}, {"name"=>"cost_center_id", "type"=>"category"}]}, "build_schedule"=>"weekly", "track_schedule"=>nil, "algorithm"=>"naive_bayes", "target_key"=>"location_id", "target_key_type"=>"category", "split_key"=>"submitted_at", "split_key_type"=>"datetime", "model_klass"=>"PurchaseRequest", "pivot_keys": ["created_by_id"]}, 
       {"config"=>{"fields"=>[{"name"=>"created_by_id", "type"=>"category", "value"=>"{{record.created_by_id}}"}, {"name"=>"vendor_id", "type"=>"category"}]}, "build_schedule"=>"weekly", "track_schedule"=>nil, "algorithm"=>"naive_bayes", "target_key"=>"policy_id", "target_key_type"=>"category", "split_key"=>"submitted_at", "split_key_type"=>"datetime", "model_klass"=>"PurchaseOrder", "pivot_keys": ["vendor_id"]}, 
       {"config"=>{"fields"=>[{"name"=>"created_by_id", "type"=>"category", "value"=>"{{record.created_by_id}}"}, {"name"=>"policy_id", "type"=>"category"}, {"name"=>"vendor_id", "type"=>"category"}]}, "build_schedule"=>"weekly", "track_schedule"=>nil, "algorithm"=>"naive_bayes", "target_key"=>"department_id", "target_key_type"=>"category", "split_key"=>"submitted_at", "split_key_type"=>"datetime", "model_klass"=>"PurchaseOrder", "pivot_keys": ["vendor_id"]}, 
       {"config"=>{"fields"=>[{"name"=>"created_by_id", "type"=>"category", "value"=>"{{record.created_by_id}}"}, {"name"=>"policy_id", "type"=>"category"}, {"name"=>"vendor_id", "type"=>"category"}]}, "build_schedule"=>"weekly", "track_schedule"=>nil, "algorithm"=>"naive_bayes", "target_key"=>"cost_center_id", "target_key_type"=>"category", "split_key"=>"submitted_at", "split_key_type"=>"datetime", "model_klass"=>"PurchaseOrder", "pivot_keys": ["vendor_id"]}, 
       {"config"=>{"fields"=>[{"name"=>"created_by_id", "type"=>"category", "value"=>"{{record.created_by_id}}"}, {"name"=>"policy_id", "type"=>"category"}, {"name"=>"vendor_id", "type"=>"category"}, {"name"=>"department_id", "type"=>"category"}, {"name"=>"cost_center_id", "type"=>"category"}]}, "build_schedule"=>"weekly", "track_schedule"=>nil, "algorithm"=>"naive_bayes", "target_key"=>"location_id", "target_key_type"=>"category", "split_key"=>"submitted_at", "split_key_type"=>"datetime", "model_klass"=>"PurchaseOrder", "pivot_keys": ["vendor_id"]}, 
       {"config"=>{"fields"=>[{"name"=>"created_by_id", "type"=>"category", "value"=>"{{record.created_by_id}}"}, {"name"=>"policy_id", "type"=>"category"}, {"name"=>"vendor_id", "type"=>"category"}, {"name"=>"department_id", "type"=>"category"}, {"name"=>"cost_center_id", "type"=>"category"}]}, "build_schedule"=>"weekly", "track_schedule"=>nil, "algorithm"=>"naive_bayes", "target_key"=>"delivery_location_id", "target_key_type"=>"category", "split_key"=>"submitted_at", "split_key_type"=>"datetime", "model_klass"=>"PurchaseOrder", "pivot_keys": ["vendor_id"]}, 
       {"config"=>{"fields"=>[{"name"=>"created_by_id", "type"=>"category", "value"=>"{{record.created_by_id}}"}]}, "build_schedule"=>"weekly", "track_schedule"=>nil, "algorithm"=>"naive_bayes", "target_key"=>"policy_id", "target_key_type"=>"category", "split_key"=>"submitted_at", "split_key_type"=>"datetime", "model_klass"=>"BankPaymentRequest", "pivot_keys": ["created_by_id"]}]
      .each do |config|
        next if MlModel::Monitor.where(company_id: company.id, model_klass: config['model_klass'], target_key: config['target_key']).count > 0

        MlModel::Monitor.create(config.merge(company_id: company.id))
      end
    end
  end

  def prepare_record(record, options = {})
    data = super(record)
    config['fields']&.each do |field|
      value = format(get_value(record, field), field['type'])
      data[field['name']] = value
    end
    data
  end

  def prepare_prediction(data, options = {})
    config['fields']&.each do |field|
      data[field['name']] = format(data[field['name']], field['type'])
    end
    data[split_key] = format(data[split_key], split_key_type)
    data
  end

  def get_value(record, field)
    if field['value'].present?
      record.to_exposure.template(field['value'])
    else
      record.send(field['name'])
    end
  end

end
