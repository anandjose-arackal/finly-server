class Forms::API::Validation
  include DynamicAttributes
  include Forms::API::Rule::DSL

  instance_attr :entity_path
  instance_attr :id
  instance_attr :custom, default: false
  instance_attr :internal, default: true
  instance_attr :is_updated, default: false
  instance_attr :can_be_updated, default: false

  def initialize(params={}, &block)
    params.each_pair do |key, value|
      self.send("#{key}=", value)
    end
    instance_eval &block if block_given?

    raise "No rules provided for the validation" if rules.blank?
    if self.id.blank?
      raise "Validation ID cannot be blank for #{self.entity_path}"
    end
  end

  def sync(company, form_model)
    form_model.where.first_or_create
  end

end