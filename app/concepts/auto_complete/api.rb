class AutoComplete::API < Transactions::API
  include DynamicAttributes
  extend Dry::Container::Mixin

  class_attr :model
  class_attr :resolver
  class_attr :json_builder
  class_attr :max_per_page, default: 10
  class_attr :search_key

  pass :define_pagination
  pass :define_search
  step Resolver::Transactions::Load(builder: :resolver_builder, paginate: true)
  step :render

  def define_pagination(context, params:, **)
    params[:page] ||= 1
    params[:per_page] = self.class.max_per_page if params[:per_page].blank?
    params[:per_page] = [params[:per_page], self.class.max_per_page].min
    context[:page] = params[:page]
    context[:per_page] = params[:per_page]
  end

  def define_search(context, params:, **)
    raise "Search key is not defined for #{self.class.name}" unless self.class.search_key.present?

    params[:q] = {}
    params[:q][self.class.search_key] = params["search"]
  end

  def render(context, options)
    list = []
    context['model.records'].each do |record|
      list << render_record(context, **options.merge(record: record))
    end
    context['model.records.json'] = list
    true
  end

  def render_record(context, record:, **)
    raise "JSON Builder is not defined for #{self.class.name}" unless json_builder.present?

    if json_builder[:block]
      json_builder[:block].call(context, record)
    elsif json_builder[:args]
      json = {}
      json_builder[:args].each do |attribute|
        json[attribute] = record.send(attribute)
      end
      json
    end

  end

  protected

  def self.json(*args, &block)
    json_builder({args: args, block: block})
  end

  def json_builder
    self.class.json_builder
  end

  def resolver_builder(context, options)
    self.class.resolver || self.class.model&.resolver
  end

end