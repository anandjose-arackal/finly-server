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
#  pmml            :text(65535)
#  form_id         :string(255)
#  parent_id       :string(255)
#  parent_type     :string(255)
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

  def prepare_record(record)
    data = super(record)
    config['fields']&.each do |field|
      value = format(get_value(record, field), field['type'])
      data[field['name']] = value
    end
    data
  end

  def prepare_prediction(data)
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
