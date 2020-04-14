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

  def self.config(user)
    config = {fixed: [], dynamic: []}
    columns.each do |column_key, column|
      if column.fixed
        config[:fixed] << column.config(user)
      else
        config[:dynamic] << column.config(user)
      end
    end
    config
  end

  def self.resolve(context)
    if context["params"]["q"].present?
      context["params"]["q"] = Filters::Sanitizer.perform(context["params"]["q"])
    end

    # Todo support resolver[:params] to be a proc to execute dynamic filters
    # context["params"].deep_merge!(resolver[:params])

    resolver_klass = Resolver::Router[resolver[:route]]&.first&.klass
    raise "Resolver with route #{resolver[:route]} not found" if resolver_klass.blank?

    Resolver::Transactions::Resolve.with(context, resolver_klass, paginate: true, filter: true)
  end

  def self.include_associations!(collection, required_columns)
    includes = []
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
    {reference: record_exposure.template(reference), columns: map}
  end

  def self.data_provider(user, record, record_exposure)
    self
  end

end