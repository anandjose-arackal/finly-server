class Lookup::API < Transactions::API
  include DynamicAttributes
  extend Dry::Container::Mixin
  include Lookup::DSL

  pass :define_pagination
  pass :define_search
  step Resolver::Transactions::Load(builder: :resolver_builder, paginate: true)
  pass :include_associations
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

    params[:q] = params[:q] || {}
    params[:q][self.class.search_key] = params['search']
  end

  def include_associations(context, params:, **)
    context['model.records'] = context['model.records'].includes(self.class.associations_to_include)
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
    attributes.each_pair do |id, attribute|
      if attribute.value.is_a?(Symbol)
        data[attribute.id] = exposure.send(attribute.value)
      else
        data[attribute.id] = exposure.template(attribute.value.to_s)
      end
    end
    data
  end

  protected

  def attributes
    self.class.attributes
  end

  def resolver_builder(context, options)
    return self.class.resolver if self.class.resolver.present?

    raise "Resolver route or model is not defined for #{self.class.name}"
  end

end