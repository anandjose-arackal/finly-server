class Lookup::API < Transactions::API
  include DynamicAttributes
  extend Dry::Container::Mixin
  include Lookup::DSL

  pass :define_pagination
  pass :define_search
  step Resolver::Transactions::Load(builder: :resolver_builder, paginate: true)
  pass :include_associations
  step :render_headers
  step :render

  def define_pagination(context, params:, **)
    params[:page] ||= 1
    params[:per_page] ||= self.class.max_per_page
    params[:per_page] = params[:per_page].to_i
    params[:per_page] = [params[:per_page], self.class.max_per_page].min
    context[:page] = params[:page]
    context[:per_page] = params[:per_page]
  end

  def define_search(context, params:, **)
    raise "Search key is not defined for #{self.class.name}" unless self.search_key(context).present?

    params[:q] = params[:q] || {}
    params[:q][self.search_key(context)] = params['search']
    params[:q]['deleted_at_null'] = 1 # Show only non-deleted records
  end

  def include_associations(context, params:, **)
    context['model.records'] = context['model.records'].includes(self.associations_to_include)
  end

  def render_headers(context, **)
    context[:headers] = attributes(context).as_json
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
    exposure = record.to_exposure
    data = {}
    attributes(context).each_pair do |id, attribute|
      if attribute.value.is_a?(Symbol)
        data[attribute.id] = exposure.send(attribute.value)
      else
        data[attribute.id] = exposure.template(attribute.value.to_s)
      end
    end
    data
  end

  protected

  def associations_to_include
    self.class.associations_to_include
  end

  def search_key(context)
    self.class.search_key
  end

  def attributes(context)
    self.class.attributes
  end

  def resolver_builder(context, options)
    return self.class.resolver if self.class.resolver.present?

    raise "Resolver route or model is not defined for #{self.class.name}"
  end

end