class Forms::API::Entity::Section
  include DynamicAttributes
  include Forms::API::Entity::Registry
  attr_accessor :section_id, :title, :block, :form, :field_path, :options, :associate_custom_fields

  def initialize(form, section_id, options, &block)
    self.form = form
    self.section_id = section_id
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
            section_id: section_id
        }
    )
  end

  def section
    section_id
  end

end