class Templates::Cloner

  attr_accessor :context, :template, :block

  def self.call(template, context, &block)
    new(template, context, &block).clone
  end

  def initialize(template, context, &block)
    self.context = context
    self.template = template
    self.block = block
    instance_exec context, template, &block if block_given?
  end

  def templates
    context.templates
  end

  def clone
    parent = context.parent
    association_name = context.association_name
    if parent.present? and association_name.present?
      # has_many association
      if parent.send(association_name).respond_to?(:each)
        return parent.send(association_name).new(clone_attrs(template))
      else
        # belongs_to/has_one association
        return parent.send("build_#{association_name}", clone_attrs(template))
      end
    else
      return template.class.new(clone_attrs(template))
    end
  end

  def clone_attrs(template)
    attrs = template.attributes.except('id', 'uuid', 'created_at', 'updated_at', 'deleted_at')
    assignment = {}
    setters.each do |attribute, value|
      assignment[attribute] = Transactions::Evaluator.eval_proc(context, value, context, template)
    end
    assignment
    attrs.merge(assignment)
  end

  def setters
    @setters ||= {}
  end

  def set(attribute, value)
    setters[attribute] = value
  end

end