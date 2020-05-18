class Filters::API::Attribute

  attr_accessor :field_key, :label, :field_type, :choices, :hint, :simple, :custom_field_id

  # Includes: Used for capturing the data points to be included to optimize the fetch for the current record
  # Simple is used to identify if the filter should be a part of the simple filter or not
  def initialize(field_key:, label:, hint:, field_type:, choices: nil, simple: false, custom_field_id: nil)
    self.field_key = field_key
    self.label = label
    self.hint = hint
    self.field_type = field_type
    self.choices = choices
    self.simple = simple
    self.custom_field_id = custom_field_id
  end

  def operators
    op = Forms::API::Entity::Registry.types[field_type].operators

    # as the ransacker :custom_fields_value_search has issues with not query, remove all not conditions
    return op.reject { |o| o.to_s.start_with?("not_") } if custom_field_id.present?

    op
  end

  def build(user)
    params = {
        field_key: field_key,
        label: label,
        hint: hint,
        field_type: field_type,
        simple: simple,
        operators: operators,
        args: {filter_id: field_key}
    }
    if custom_field_id.present?
      # Generate unique ID for custom fields
      params[:args] = {field_id: "#{field_key}_#{custom_field_id.first}", custom_field_id: custom_field_id}
    end

    if choices.present?
      choices_data = choices.build(user: user)
      # If the choices is partial, then set the field type as lookup.
      if StringUtils.to_bool(choices_data[:partial]) and field_type.to_s == 'dropdown'
        params[:field_type] = :lookup
      end

      params[:choices] = choices_data[:choices]
    end
    params
  end

  module Builder
    extend ActiveSupport::Concern

    included do
      class_attr :attributes, default: {}.with_indifferent_access
    end

    class_methods do
      # Check if the attribute is defined
      def exists?(filter_key)
        attributes[filter_key].present?
      end

      def attribute(field_key, label: nil, type: :text, hint: "Select Value", choices: nil, simple: false)
        raise "#{field_key} is already defined for class #{self.name}" if exists?(field_key)

        label ||= field_key.to_s.humanize

        attributes[field_key] = Filters::API::Attribute.new(
            {
                field_key: field_key,
                label: label,
                field_type: type,
                hint: hint,
                choices: choices,
                simple: simple
            }
        )
      end

      def custom_fields(*parent_type, prefix: nil)
        @custom_fields ||= []
        @custom_fields << {parent_type: parent_type, prefix: prefix} if parent_type.present?
        @custom_fields
      end

      def build(user)
        filters = []
        attributes.each do |field_key, attribute|
          filters << attribute.build(user)
        end
        if custom_fields.present?
          build_custom_fields(user, filters)
        end
        filters
      end

      def custom_field_configurations
        parent_types = custom_fields.map { |cf| cf[:parent_type] }
        user.company.all_field_configurations.where(is_deleted: false, deleted_at: nil, enabled: true)
            .ransack(field_parent_mappings_field_parent_type_id_in: FieldParentType.ids_for(*parent_types))
            .result
      end

      # Dynamically adds all custom fields as attributes. Supported types are text and dropdown.
      # Dropdown gives all dropdown options for selection. All other fields are added as text
      def build_custom_fields(user, filters)
        configs = {}
        field_configurations = user.company.all_field_configurations.where(is_deleted: false, deleted_at: nil, enabled: true).includes(:drop_down_items)
        custom_fields.each do |custom_field_config|
          fc = field_configurations.ransack(field_parent_mappings_field_parent_type_id_in: FieldParentType.ids_for(*custom_field_config[:parent_type])).result
          fc.each do |field_configuration|
            if configs[field_configuration.field_name].blank?
              field_key = "custom_fields_value_search"
              field_key = "#{custom_field_config[:prefix]}_#{field_key}" if custom_field_config[:prefix].present?
              configs[field_configuration.field_name] = {
                  field_key: field_key,
                  hint: field_configuration.field_name,
                  label: field_configuration.field_name,
                  field_type: :text,
                  simple: false,
                  custom_field_id: [field_configuration.id]
              }
            else
              configs[field_configuration.field_name][:custom_field_id] << field_configuration.id
            end

            # In-case the type is dropdown, set the type as dropdown and add all relevant choices
            if field_configuration.field_type_id == FieldType.id_for(:drop_down)
              configs[field_configuration.field_name][:field_type] = :dropdown
              configs[field_configuration.field_name][:choices] ||= []
              configs[field_configuration.field_name][:choices] += field_configuration.drop_down_items.map { |i| {id: i.name, name: i.name} }
              configs[field_configuration.field_name][:choices].uniq!
            end
          end
        end

        configs.each_pair do |name, config|
          if config[:choices].present?
            config[:choices] = Choices[:list].(*config[:choices])
          end
          attribute = Filters::API::Attribute.new(config)
          filters << attribute.build(user)
        end
      end
    end
  end

end