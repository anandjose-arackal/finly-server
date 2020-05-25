class Templates::API
  include DynamicAttributes

  class_attr :templates, default: {}
  class_attr :associations, default: {}

  attr_accessor :template

  def initialize(template)
    self.template = template
    # instance_exec params, &self.class.root
  end

  def sync(params)
    # context = {params: params, templates: self.class.templates, template: template, parent: root_record, root_record: root_record}
    root_record = Templates::Builder.(template: template, params: params, api: self, template: template, &self.class.root)
    root_record
  end

  def self.root(&block)
    @root = block if block_given?
    @root
  end

  def self.template(name, &evaluator)
    templates[name] = evaluator
  end

end