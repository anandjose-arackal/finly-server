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
class MlModel::FormEntityModel < MlModel
  include TemplateClonable

  belongs_to :form
  has_many :dependent_entity_mappings, class_name: 'MlModelDependentEntity', foreign_key: :ml_model_id

  validates :form, presence: true
  validates :parent, presence: true
  validate :is_form_entities_valid?

  alias_attribute :target_entity, :parent

  def self.system_model(model_klass:, form_entity_key:, dependent_entity_keys: [], attributes: {})
    model = self.new(
      build_schedule: 'weekly',
      target_key: form_entity_key,
      target_key_type: 'category',
      split_key: 'submitted_at',
      split_key_type: 'datetime',
      model_klass: model_klass
    )
    model.assign_attributes(attributes) if attributes.present?
    model.template_reference[:form_entity_key] = form_entity_key
    dependent_entity_keys.each do |dependent_entity_key|
      dependent_entity_mapping = model.dependent_entity_mappings.new
      dependent_entity_mapping.template_reference[:form_entity_key] = dependent_entity_key
    end
    model
  end

  def includes(records)
    return records.includes_for_contract if records.respond_to?(:includes_for_contract)

    records
  end

  # def self.build(options = {})
  #   form_ids = self.all.distinct(:parent_id).pluck(:parent_id).uniq
  #   form_ids.each do |form_id|
  #     self.where(parent_id: form_id).find_each do |model|
  #       model.build_model
  #       model.clear_model_cache
  #     end
  #   end
  # end

  def form_cache!(value)
    @form_cache = value
  end

  def form_cache
    @form_cache ||= {}
  end

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

    data = {}
    target_paths = target_entity.entity_path.split('.')

    # Todo - target entity is in line item, this is working only if target entity is not within a collection
    # target_row_data = form_data
    # ent_path = ''
    # target_paths.each do |ent_key|
    #   break if ent_key == target_entity.entity_key
    #
    #   ent_path += '.' unless ent_path.blank?
    #   ent_path += ent_key
    #
    #   target_row_data = form_data.dig(ent_key)
    # end

    if target_entity.is_in_collection?(form: form)

      # Todo - target entity is in line item, this is working only if target entity is not within a collection
      return nil
      # data = []
      # target_parent_paths = target_paths.pop
      #
      # item = {}
      # dependent_entity_mappings.each do |mapping|
      # end
      # data << item
    else
      # Assumption is that target and dependent is not in line items
      data[target_entity.entity_key] = format(form_data.dig(*target_paths), 'category')
      dependent_entity_mappings.each do |mapping|
        dependent_entity = mapping.form_entity
        dependent_paths = dependent_entity.entity_path.split('.')
        # Assumption is that the data points for all models are categorical, and not numerical.
        # Hence converting it to a string
        data[dependent_entity.entity_key] = format(form_data.dig(*dependent_paths), 'category')
      end

      # Add the split key
      data[split_key] = format(record.send(split_key), split_key_type) if split_key.present?
    end

    data
  end

  protected

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
