# == Schema Information
#
# Table name: ml_models
#
#  id              :bigint           not null, primary key
#  company_id      :integer          not null
#  parent_type     :string(255)
#  parent_id       :bigint
#  type            :string(255)      not null
#  config          :text(4294967295)
#  built_at        :datetime
#  build_schedule  :string(255)
#  track_schedule  :string(255)
#  build_duration  :integer
#  tracked_at      :datetime
#  pmml            :text(4294967295)
#  algorithm       :string(255)
#  target_key      :string(255)      not null
#  target_key_type :string(255)      not null
#  split_key       :string(255)
#  split_key_type  :string(255)
#  model_klass     :string(255)
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
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

  def records
    Object.const_get(model_klass).all
  end

  def prepare_record(record)
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

  def build_model
    data = prepare_data
    return false if data.blank?

    model = Eps::Model.new(data, target: target_key, algorithm: algorithm.to_sym)
    return false unless update(pmml: model.to_pmml, built_at: DateTime.now)

    # Clear the cache
    @model = model
    true
  end

  def predict(data = {})
    return nil unless model.present?

    data ||= {}
    data = data.with_indifferent_access
    model.predict(prepare_prediction(data))
  end

  def track_predictions
    return false if model.blank?

    # Predictions will be tracked from the last build time
    return false if built_at.blank?

    # Scope records which have not been synced or have been updated after the last build
    records = self.records.where.not("id in (#{predictions.select(:record_id).to_sql})")
    records = records.or(records.where('updated_at > ?', tracked_at))

    # Scope records with split_key timestamp after the model was built.
    # This is to ensure we are not tracking predictions for records which were used for training
    # the model
    if split_key.present?
      records = records.where.not(:"#{split_key}" => nil).where("#{split_key} > ?", built_at)
    end

    records.find_each do |record|
      record_data = prepare_record(record)

      actual = record_data[target_key]
      prediction = model.predict(record_data.except(target_key))

      # Update existing record if available
      prediction_model = predictions.find_or_initialize_by(
        record: record,
        ml_model: self,
        company_id: self.company_id
      )
      prediction_model.update(
        actual_value: actual,
        predicted_value: prediction
      )
    end
    update(tracked_at: DateTime.now)

    true
  end

  def prepare_data(after: nil, records: nil)
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
      data << prepare_record(record)
    end
    data
  end

  def prepare_prediction(data)
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
