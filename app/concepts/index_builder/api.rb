class IndexBuilder::API
  include Column::Builder
  include DynamicAttributes
  include IndexBuilder::Counter::DSL

  def self.resolver(route = nil, params: {})
    @resolver = {route: route, params: params} if route

    @resolver
  end

  def self.reference(id = nil, args = {})
    @reference = {id: id, args: args} if id.present?

    @reference ||= {id: '{{record.id}}', args: {}}
  end

  def self.includes(args)
    @global_includes = args
  end

  def self.config(user)
    config = {fixed: [], dynamic: []}
    columns.each do |column_key, column|
      if column.fixed
        config[:fixed] << column.config(user)
      else
        config[:dynamic] << column.config(user)
      end
    end

    self.config_custom_fields(user, config)
    config
  end

  def self.config_custom_fields(user, config)
    return unless self.custom_fields

    field_configurations = user.company.field_configurations.joins(:field_parent_mappings)
                               .where(is_deleted: false, deleted_at: nil)
                               .where(field_parent_mappings: {field_parent_type_id: FieldParentType.ids_for(*custom_fields[:type])})
    map = {}
    field_configurations&.each do |field_config|
      map[field_config.field_name] ||= []
      map[field_config.field_name] << field_config.id
    end
    map.each_pair do |field_name, ids|
      config[:dynamic] << {
          column_key: "cf_#{ids.join("_")}",
          label: field_name,
          sort: false,
          default: false,
      }
    end
  end

  def self.resolve(context)
    if context["params"]["q"].present?
      context["params"]["q"] = Filters::Sanitizer.perform(context["params"]["q"])
    end

    # Todo support resolver[:params] to be a proc to execute dynamic filters
    # context["params"].deep_merge!(resolver[:params])

    raise 'Resolver not found' if resolver[:route].blank?

    Resolver::Transactions::Resolve.with(context, route: resolver[:route], paginate: true, filter: true)
  end

  def self.include_associations!(collection, required_columns)
    includes = @global_includes || []
    includes = [includes] unless includes.is_a?(Array)

    # include system fields
    attrs = columns.select do |column_key, attr|
      (required_columns.blank? and attr.default) or (required_columns.present? and (required_columns.include?(column_key.to_s) or required_columns.include?(column_key.to_sym)))
    end

    attrs.each do |column_key, column|
      if column.includes.is_a?(Hash)
        includes += [column.includes]
      else
        includes += column.includes
      end

    end

    #include custom field
    if required_columns&.select { |column| column.starts_with?("cf_") }&.present?
      includes += (@custom_fields&.dig(:includes) || [])
    end

    collection.includes(includes.uniq)
  end

  def self.build(user, record, required_columns)
    record_exposure = record.to_exposure
    map = {}
    self.columns.each do |column_key, column|
      next if required_columns.present? and not (required_columns.include?(column_key.to_s) or required_columns.include?(column_key.to_sym))
      next if required_columns.blank? and not column.default

      data_provider = data_provider(user, record, record_exposure)

      map[column.column_key] = column.build(data_provider, user, record, record_exposure)
    end
    build_custom_fields(map, user, record, record_exposure, required_columns)
    {reference: record_exposure.template(reference), columns: map}
  end

  def self.build_custom_fields(map, user, record, record_exposure, required_columns)
    return unless required_columns.present?

    required_columns.select { |column| column.starts_with?("cf_") }&.each do |custom_field_column|
      ids = custom_field_column.split("_")
      custom_fields = self.custom_fields[:path].call(record)
      required_cf = custom_fields.select { |cf| ids.include?(cf.field_configuration_id.to_s) }&.first
      text_field = IndexBuilder::ContentTypes::Text.new({value: required_cf&.configured_field_value.to_s})
      map[custom_field_column] = [text_field.build(self, user, record, record_exposure)]
    end
  end

  # Data provider is used for reusing classes for fetching data
  def self.data_provider(user, record, record_exposure)
    self
  end

end