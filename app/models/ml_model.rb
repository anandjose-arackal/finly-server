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
#  pmml            :text(4294967295)
#
class MlModel < ApplicationRecord
  include DynamicAttributes
  include MlModels::Schema
  include Dry::Monads[:result]

  belongs_to :parent, optional: true, polymorphic: true
  belongs_to :company

  has_many :predictions, class_name: 'MlModelPrediction'

  serialize :config, JSON

  FIELD_TYPES = { number: 'number', text: 'text', category: 'category', datetime: 'datetime' }
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

  # Rebuilds all models
  def self.build(options = {})
    self.all.find_each do |model|
      model.build_model(options)
      model.clear_model_cache
    end

    true
  end

  # Used by +records+ function to eager load the records to prevent N+1 query problem
  def includes(records)
    records
  end

  # Provides all the records which will be used for training models and for tracking predictions
  def records
    records = Object.const_get(model_klass).all.where(company_id: company_id)
    records = includes(records)
    # This will limit the records to just the last 12 months
    # records = records.where("#{split_key} > #{1.year.ago}") if split_key.present?
    records
  end

  def prepare_record(record, options = {})
    record_data = {}
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

  def model
    return nil unless pmml.present?

    # TODO cache permanently
    @model ||= Eps::Model.load_pmml(pmml)
  end

  def clear_model_cache
    @model = nil
  end

  def build_model(options = {})
    start_time = Time.now
    data = prepare_data
    return false if data.blank?

    begin
      model = Eps::Model.new(data, target: target_key, algorithm: algorithm.to_sym)
    rescue StandardError => e
      debugger
      raise e
    end
    return false unless update(pmml: model.to_pmml, built_at: DateTime.now, build_duration: (Time.now - start_time))

    # Clear the cache
    @model = model

    true
  end

  def predict(data = {}, options = {})
    return nil unless model.present?

    data ||= {}
    data = data.with_indifferent_access
    model.predict(prepare_prediction(data))
  end

  # Runs through all records which were created since the last time the model was built to measure the prediction
  # Captures the accuracy and prediction in models/MlModelPrediction
  def track_predictions(options = {})
    return false if model.blank?

    # Predictions will be tracked from the last build time
    return false if built_at.blank?

    records = self.records
    # Scope records which have not been synced or have been updated after the last build
    records = records.where.not(
      "id in (#{predictions.where(record_type: records.model).select(:record_id).to_sql})"
    )
    records = records.or(records.where('updated_at > ?', tracked_at))

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
          prediction = model.predict(record_data.except(target_key))

          # Bulk import to improve performance
          import_data << {
            record_id: record.id,
            record_type: record.class.name,
            ml_model_id: self.id,
            company_id: self.company_id,
            actual_value: actual,
            predicted_value: prediction,
            is_accurate_prediction: (actual.to_s == prediction.to_s)
          }
          predicted_records << record.id
        end
      end
      update(tracked_at: DateTime.now)
      MlModelPrediction.import import_data, on_duplicate_key_update: [:record_id, :record_type]
    end

    true
  end

  def prepare_data(after: nil, records: nil, options: {})
    data = []
    records = self.records if records.nil?

    # Scope records with split_key timestamp after the model was built.
    # This is to ensure we are not tracking predictions for records which
    # were used for training the model
    if split_key.present?
      records = records.where.not(:"#{split_key}" => nil)
      if after.present?
        records = records.where("#{split_key} > ?", after)
      end
    end

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

  def prepare_prediction(data, options = {})
    data
  end

  def algorithm
    super&.to_sym || :naive_bayes
  end

  def format(value, type)
    return value.to_s if %w[text category].include?(type.to_s)
    return value.strftime('%Y-%m-%d').to_s if %w[datetime].include?(type.to_s) and value.present?

    value
  end

  def validate_schema
    unless valid_schema?.success?
      errors.add :schema, 'is invalid'
    end
  end

end
