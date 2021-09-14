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
class MlModel::FormEntityModel < MlModel
  include TemplateClonable

  belongs_to :form
  has_many :dependent_entity_mappings, class_name: 'MlModelDependentEntity', foreign_key: :ml_model_id

  validates :form, presence: true
  validates :parent, presence: true
  validate :is_form_entities_valid?

  alias_attribute :target_entity, :parent

  def self.system_model(model_klass:, form_entity_path:, dependent_entity_paths: [], attributes: {})
    model = self.new(
      build_schedule: 'weekly',
      target_key: form_entity_path,
      target_key_type: 'category',
      split_key: 'submitted_at',
      split_key_type: 'datetime',
      model_klass: model_klass
    )
    model.assign_attributes(attributes) if attributes.present?
    model.template_reference[:form_entity_path] = form_entity_path
    dependent_entity_paths.each do |dependent_entity_key|
      dependent_entity_mapping = model.dependent_entity_mappings.new
      dependent_entity_mapping.template_reference[:form_entity_path] = dependent_entity_key
    end
    model
  end

  def includes(records)
    return records.includes_for_contract if records.respond_to?(:includes_for_contract)

    records
  end

  def form_cache!(value)
    @form_cache = value
  end

  def form_cache
    @form_cache ||= {}
  end

  # Builds the record hash for training from the form contract.
  # If the target_key is within a line item, it will generate one entry per line item for training
  # The generated hash will have entity_path as the keys
  #
  # Valid combinations
  #   1. target_key -> header, dependent_keys -> header
  #   2. target_key -> line_items, dependent_keys -> header
  #   3. target_key -> line_items, dependent_keys -> line_items (same as target_key)
  #
  # Invalid Combinations
  #   1. target_key -> header, dependent_keys -> line_items
  def prepare_record(record, options = {})
    form_klass = record.form_klass
    return if form_klass.blank?

    if form_cache.dig(record.company_id, form_klass).blank?
      return nil if record.form.nil?

      form_cache[record.company_id] ||= {}
      form_cache[record.company_id][form_klass] ||= record.form.preload_for_contract!
    end

    form = form_cache[record.company_id][form_klass]

    return nil if form.blank?

    contract = form.contract(record.created_by).new(record)
    form_data = contract.to_form

    dependent_entity_paths = dependent_entity_mappings.map { |ent| ent.form_entity.entity_path }
    data = extract(form_data, form_data, target_entity.entity_path, target_entity.entity_path, dependent_entity_paths)

    if split_key.present? and data.is_a?(Array)
      data.each do |item|
        item[split_key] = format(record.send(split_key), split_key_type) if split_key.present?
      end
    else
      data[split_key] = format(record.send(split_key), split_key_type) if split_key.present?
    end

    data
  end

  def prepare_prediction(data, options = {})
    dependent_entity_mappings.includes(:form_entity).find_each do |dependent_entity_mapping|
      dependent_entity_key = dependent_entity_mapping.form_entity.entity_key
      data[dependent_entity_key] = format(data[dependent_entity_key], 'category')
    end
    data[split_key] = format(data[split_key], split_key_type) if split_key.present?
    data
  end

  protected

  # extract works by splitting the target_entity_path and navigating through each of the paths.
  # It will generate one record per item in array if the path has an array.
  def extract(row_data, form_data, target_entity_path, target_entity_paths, dependent_entity_paths)
    target_entity_paths = target_entity_paths.split('.') unless target_entity_paths.is_a?(Array)
    ent_key = target_entity_paths.shift
    value = row_data[ent_key]
    if value.is_a?(Hash)
      return extract(row_data[ent_key], form_data, target_entity_path, target_entity_paths, dependent_entity_paths)
    elsif value.is_a?(Array)
      data = []
      value.each do |row|
        data << extract(row, form_data, target_entity_path, target_entity_paths, dependent_entity_paths)
      end
      return data
    else
      data = {}
      data[target_entity_path] = format(value, 'category')
      dependent_entity_paths.each do |dep_ent_path|
        # Assumption is that dependent_entity should either be in the same row as the target or in the form header
        dep_ent_paths = dep_ent_path.split('.')
        dep_ent_key = dep_ent_paths.last
        dep_ent_value = row_data[dep_ent_key] || form_data.dig(*dep_ent_paths)
        data[dep_ent_path] = format(dep_ent_value, 'category')
      end
      return data
    end
  end

  def is_form_entities_valid?
    return true if dependent_entity_mappings.blank?

    is_target_in_collection = target_entity.is_in_collection?

    dependent_entities = dependent_entity_mappings.map { |mapping|
      mapping.form_entity
    }

    dependent_entities.each do |dependent_entity|
      is_dependent_in_collection = dependent_entity.is_in_collection?

      # Valid
      # target -> header, dependent: header
      next unless is_target_in_collection or is_dependent_in_collection

      # Valid
      # target -> line_item, dependent: line_items (Same as target)
      # target -> line_item, dependent: header (Same as target)
      if is_target_in_collection
        next unless is_dependent_in_collection

        next if target_entity.parent_id == dependent_entity.parent_id
      end

      # Invalid
      errors.add :dependent_field, "#{dependent_entity.label} cannot be selected with #{target_entity.label}"
    end
  end

end
