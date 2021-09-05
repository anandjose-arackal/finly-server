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
class MlModel < ApplicationRecord
  include DynamicAttributes
  include MlModels::Schema
  include Dry::Monads[:result]

  RECORD_LIMIT = 10000

  belongs_to :parent, optional: true, polymorphic: true
  belongs_to :company

  has_many :predictions, class_name: "MlModelPrediction"
  has_many :model_pmmls, class_name: "MlModelPmml"

  serialize :config, JSON
  serialize :pivot_keys, JSON

  FIELD_TYPES = { number: "number", text: "text", category: "category", datetime: "datetime" }
  SCHEDULES = %w[hourly daily weekly monthly].freeze

  validates :algorithm, presence: { in: %w[naive_bayes] }, allow_nil: true
  validates :build_schedule, presence: { in: SCHEDULES }
  validates :track_schedule, presence: { in: SCHEDULES }, allow_nil: true
  validates :target_key, presence: true
  validates :company_id, presence: true
  validates :type, presence: true
  validates :target_key, presence: true
  validates :target_key_type, presence: true
  validates :split_key, presence: true
  validates :split_key_type, presence: true
  validates :model_klass, presence: true
  validate :validate_schema

  scope :enabled, -> {
    prediction_enabled_company_ids = FeatureSubscription.where(predictions_enabled: true).pluck(:company_id)
    where(company_id: prediction_enabled_company_ids)
  }

  # Rebuilds all models
  def self.build(options = {})
    self.all.enabled.find_each do |model|
      model.build_model(options)
    end

    true
  end

  # Used by +records+ function to eager load the records to prevent N+1 query problem
  def includes(records)
    records
  end

  # Provides all the records which will be used for training models and for tracking predictions
  def records(after: nil)
    records = Object.const_get(model_klass).all.where(company_id: company_id)
    records = includes(records)
    
    # Scope records with split_key timestamp after the model was built.
    # This is to ensure we are not tracking predictions for records which
    # were used for training the model
    if split_key.present?
      records = records.where.not(:"#{split_key}" => nil)
      if after.present?
        records = records.where("#{split_key} > ?", after)
      end
    end

    records = records.reorder(id: :desc)

    records
  end

  def prepare_record(record, options = {})
    record_data = {}.with_indifferent_access
    record_data[split_key] = split_value(record)
    record_data[target_key] = target_value(record)
    record_data
  end

  def split_value(record)
    format(record.send(split_key), split_key_type)
  end

  def target_value(record)
    format(record.send(target_key), target_key_type)
  end

  def model(data={})
    data = data.with_indifferent_access
    pivot_key = ""
    pivot_keys.each do |pk|
      pivot_key += "/" unless pivot_key.blank?
      pivot_key += "#{pk}#{data[pk]}"
    end
    return nil if pivot_key.blank?
    model_pmml = model_pmmls.find_by(pivot: pivot_key)
    return nil unless model_pmml.present? and model_pmml.pmml.present?

    Eps::Model.load_pmml(model_pmml.pmml)
  end

  def predict(data = {}, options = {})
    data ||= {}
    data = data.with_indifferent_access
    data = prepare_prediction(data)
    model = self.model(data)
    return nil if model.blank?

    model.predict(data)
  end

  # Runs through all records which were created since the last time the model was built to measure the prediction
  # Captures the accuracy and prediction in models/MlModelPrediction
  def track_predictions(options = {})
    # Predictions will be tracked from the last build time
    return false if built_at.blank?
    return false if model_pmmls.count == 0

    records = self.records
    # Scope records which have not been synced or have been updated after the last build
    records = records.where.not(
      "id in (#{predictions.where(record_type: records.model).select(:record_id).to_sql})"
    )
    records = records.or(records.where("updated_at > ?", tracked_at))

    # Scope records with split_key timestamp after the model was built.
    # This is to ensure we are not tracking predictions for records which were used for training
    # the model
    if split_key.present?
      records = records.where.not(:"#{split_key}" => nil).where("#{split_key} > ?", built_at)
    end

    records.find_in_batches do |batch|
      predicted_records = []
      import_data = []
      batch.each do |record|
        record_dataset = prepare_record(record)
        next if record_dataset.blank?

        record_dataset = [record_dataset] unless record_dataset.is_a?(Array)
        record_dataset.each do |record_data|
          actual = record_data[target_key]
          prediction = model(record_data).predict(record_data.except(target_key)) rescue nil
          next if prediction.nil?

          # Bulk import to improve performance
          import_data << {
            record_id: record.id,
            record_type: record.class.name,
            ml_model_id: self.id,
            company_id: self.company_id,
            actual_value: actual,
            predicted_value: prediction,
            is_accurate_prediction: (actual.to_s == prediction.to_s),
          }
          predicted_records << record.id
        end
      end
      update(tracked_at: DateTime.now)

      MlModelPrediction.import import_data, on_duplicate_key_update: [:actual_value, :predicted_value, :is_accurate_prediction]
    end

    true
  end

  def build_model(options = {})
    return if pivot_keys.blank? # Pivot is required for modelling to ensure models do not grow to large sizes

    start_time = Time.now

    # This will ensure models are rebuilt only for companies which have new records created since
    # the last build
    return unless self.records(after: built_at).count > 0

    records = self.records
    data = prepare_data(records)
    pivot_and_build_models(records, data)

    update(built_at: DateTime.now, build_duration: (Time.now - start_time))

    true
  end

  # Transforms ActiveRecords collection into array of hash which can be consumed by EPS
  def prepare_data(records)
    data = []

    records.find_each do |record|
      record_dataset = prepare_record(record)
      next if record_dataset.blank?

      record_dataset = [record_dataset] unless record_dataset.is_a?(Array)
      record_dataset.each do |record_data|
        data << record_data if record_data.present?
      end
    end

    data
  end

  def pivot_and_build_models(records, data)
    unique_pivot_values = {}

    # Supporting just 2 pivot keys at the moment to minimise the possible combinations
    self.pivot_keys.first(2).each do |pivot_key|
      unique_pivot_values[pivot_key] = records.distinct.select(pivot_key).map(&pivot_key.to_sym)
    end

    pivot_1_key = pivot_keys.first
    pivot_1_unique_values = unique_pivot_values[pivot_1_key]
    pivot_2_key = pivot_keys.second
    pivot_2_unique_values = pivot_2_key.present? ? unique_pivot_values[pivot_2_key] : nil

    models = []
    pivot_1_unique_values.each do |pivot_1_value|
      if pivot_2_unique_values.present?
        pivot_2_unique_values.each do |pivot_2_value|
          filtered_data = data.select { |rec|
            (rec[pivot_1_key.to_s].present? and rec[pivot_1_key.to_s].to_s == pivot_1_value.to_s) || (rec[pivot_2_key.to_s].present? and rec[pivot_2_key.to_s].to_s == pivot_2_value.to_s)
          }
          pivot_key = "#{pivot_1_key}#{pivot_1_value}/#{pivot_2_key}#{pivot_2_value}"

          models << build_model_pmml(pivot_key, filtered_data)
        end
      else
        filtered_data = data.select { |rec|
          (rec[pivot_1_key.to_s].present? and rec[pivot_1_key.to_s].to_s == pivot_1_value.to_s)
        }
        pivot_key = "#{pivot_1_key}#{pivot_1_value}"

        models << build_model_pmml(pivot_key, filtered_data)
      end
    end

    models.reject! {|item| item.blank?}

    if models.present?
      # Import in batches of 1000
      models.each_slice(1000) do |batch|
        MlModelPmml.import(batch, on_duplicate_key_update: [:pmml])
      end
    end
  end

  def build_model_pmml(pivot, data)
    return if data.blank?

    begin
      model = Eps::Model.new(data, target: target_key, algorithm: algorithm.to_sym)
    rescue StandardError => e
      raise e
    end

    # Returning hash for bulk update
    {
      pivot: pivot,
      pmml: model.to_pmml,
      company_id: self.company_id,
      ml_model_id: self.id
    }

    # self.model_pmmls.find_or_initialize_by(pivot: pivot).update(pmml: model.to_pmml, company_id: self.company_id).as_json.except('created_at', 'updated_at', "id")
  end

  def prepare_prediction(data, options = {})
    data
  end

  def algorithm
    super&.to_sym || :naive_bayes
  end

  def format(value, type)
    return value.to_s if %w[text category].include?(type.to_s)
    return value.strftime("%Y-%m-%d").to_s if %w[datetime].include?(type.to_s) and value.present? and !value.is_a?(String)

    value
  end

  def validate_schema
    unless valid_schema?.success?
      errors.add :schema, "is invalid"
    end
  end
end
