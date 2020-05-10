class Templates::API
  include DynamicAttributes

  class_attr :templates, default: {}
  class_attr :associations, default: {}

  attr_accessor :template

  def initialize(template)
    self.template = template
  end

  def sync(params)
    root_record = instance_exec params, &self.class.root
    if root_record.blank?
      root_record = template.class.new(template.attributes.except('id', 'uuid', 'created_at', 'updated_at', 'deleted_at'))
      root_record.company_id = params[:company_id]
    end
    context = params.merge(templates: self.class.templates, template: template, parent: root_record, root_record: root_record)
    self.class.associations.each do |key, args|
      eval = Templates::Synchronizer.new(key, context, args, &args[:evaluator])
      eval.sync(template, root_record)
    end
    root_record.save unless root_record.persisted?
    root_record
  end

  def self.root(&block)
    @root = block if block_given?
    @root
  end

  def self.template(name, &evaluator)
    templates[name] = evaluator
  end

  def self.association(name, condition: nil, &evaluator)
    associations[name] = {evaluator: evaluator, condition: condition}
  end

end