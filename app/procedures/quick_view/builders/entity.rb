class QuickView::Builders::Entity < NonPersistentModel
  include QuickView::Builders::Section::Registry

  attr_accessor :key, :value, :label, :entities

  validates :key, presence: true
  validates :label, presence: true

  def initialize(config = {}, &block)
    config.each_pair do |key, value|
      self.send("#{key}=", value)
    end
    self.label ||= self.key.to_s.humanize
    self.entities ||= []
    instance_eval(&block) if block_given?
  end

  def entity(klass, config, &block)
    entity = klass.new(config, &block)
    unless entity.valid?
      raise "#{self.class.name}: #{entity.errors.full_messages}"
    end
    entities << entity
  end

  def value(options={})
    @value
  end

  def render(context, exec_context, user, record, exposure, data)
    json = {
      key: key,
      label: label,
      type: entity_type,
    }
    value = render_value(exec_context, self.value(context), user, record, exposure, data)
    if entities.present?
      json[:entities] = []
      items = value

      # items = [{}, {}] #TODO
      items&.each do |item|
        rec = nil
        exp = nil
        if item.is_a?(ActiveRecord::Base)
          rec = item
          exp = item.to_exposure
          item = exp
        end
        if item.is_a?(Exposures::API)
          exp = item
        end
        entities.each do |entity|
          json[:entities] << entity.render(context, exec_context, user, rec, exp, item)
        end
      end
    else
      json[:value] = value
    end
    json
  end

  def render_value(exec_context, retriever, user, record, exposure, data)
    retriever_context = {
      entity: self,
      user: user,
      record: record,
      exposure: exposure,
      data: data,
    }

    if retriever.is_a?(Proc)
      retriever = instance_exec retriever_context, &retriever
    end

    if retriever.is_a?(String)
      value = exposure.template(retriever)
    elsif retriever.is_a?(Symbol)
      if exec_context.respond_to?(retriever)
        value = exec_context.send(retriever, retriever_context)
      else
        value = exposure.send(retriever)
      end
    else
      value = retriever
    end

    value
  end
end
