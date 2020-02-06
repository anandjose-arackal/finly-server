class Forms::DSL::Entity::Section
  include DynamicAttributes
  include Forms::DSL::Entity::Registry
  attr_accessor :name, :block, :form, :field_path, :options, :associate_custom_fields

  def initialize(form, name, options, &block)
    self.form = form
    self.name = name
    self.options = options || {}
    self.block = block
    initialize_with(options)

    instance_eval &block if block.present?
  end

  def initialize_with(opts)
    opts.each_pair do |key, value|
      next if value.nil?
      send :"#{ key }=", value
    end
  end

  def schema
    self.options.merge(
        {
            name: name
        }
    )
  end

  def section
    name
  end

end