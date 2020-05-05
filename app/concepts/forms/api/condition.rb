class Forms::API::Condition
  include DynamicAttributes
  include Forms::API::Rule::DSL

  instance_attr :association_type
  instance_attr :association_path
  instance_attr :property
  instance_attr :rules, default: []

  def initialize(&block)
    instance_eval &block if block_given?
  end

  def entity(path)
    association_type(:entity)
    association_path(path)
  end

end