class Forms::API::Condition
  include DynamicAttributes
  include Forms::API::Rule::DSL

  instance_attr :entity_path
  instance_attr :id
  instance_attr :custom, default: false
  instance_attr :internal, default: true
  instance_attr :is_updated, default: false
  instance_attr :can_be_updated, default: false
  instance_attr :actions, default: []
  instance_attr :rules, default: []

  def initialize(params={}, &block)
    params.each_pair do |key, value|
      self.send("#{key}=", value)
    end
    instance_eval &block if block_given?

    if self.id.blank?
      raise "Condition ID cannot be blank for #{self.entity_path}"
    end
  end

  def action(property, value)
    actions << Action.new(property: property, value: value)
  end

  def sync(company, form_model)
    # form_model.conditions.find_or_create condition_key:
  end

  class Forms::API::Condition::Action
    include DynamicAttributes

    attr_accessor :property, :value

    def initialize(params)
      params.each_pair do |key, value|
        self.send("#{key}=", value)
      end
    end

  end

end