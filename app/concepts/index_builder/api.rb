class IndexBuilder::API
  include Column::Builder
  include DynamicAttributes
  include IndexBuilder::Counter::DSL

  def self.resolver(klass = nil, params: {})
    @resolver = {klass: klass, params: params} if klass

    @resolver
  end

  def self.reference(id = nil, args = {})
    @reference = {id: id, args: args}  if id.present?

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
    # Todo support resolver[:params] to be a proc to execute dynamic filters
    # context["params"].deep_merge!(resolver[:params])

    # Get requests sends the "q" as a string since it is being sent in the URL. Handling the same
    if context["params"]["q"].class.name == String.name
      context["params"]["q"] = JSON.parse(context["params"]["q"])
    end

    if context["params"]&.dig("q", "g").class.name == String.name
      context["params"]["q"]["g"] = JSON.parse(context["params"]["q"]["g"])
    end

    Resolver::Transactions::Resolve.with(context, resolver[:klass], paginate: true, filter: true)
  end

  def self.include_associations!(collection, required_columns)
    includes = []
    attrs = columns.select do |column_key, attr|
      (required_columns.blank? and attr.default) or (required_columns.present? and (required_columns.include?(column_key.to_s) or required_columns.include?(column_key.to_sym)))
    end
    attrs.each do |column_key, column|
      includes += column.includes
    end
    collection.includes(includes.uniq)
  end

  def self.build(user, record, required_columns)
    map = {}
    self.columns.each do |column_key, column|
      next if required_columns.present? and not (required_columns.include?(column_key.to_s) or required_columns.include?(column_key.to_sym))
      next if required_columns.blank? and not column.default

      map[column.column_key] = column.build(self, user, record)
    end
    {reference: record.template(reference), columns: map}
  end

end