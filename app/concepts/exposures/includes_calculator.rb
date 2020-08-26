class Exposures::IncludesCalculator
  attr_accessor :model_klass, :templates, :lookup_key

  def initialize(model_klass, templates, lookup_key)
    self.model_klass = model_klass
    self.templates = templates
    self.lookup_key = lookup_key
  end

  def self.call(model_klass, templates, lookup_key)
    new(model_klass, templates, lookup_key).parse
  end

  def merge_includes(allincludes, new_includes)
    if new_includes.is_a?(Symbol) || new_includes.is_a?(String)
      return if allincludes.include?(new_includes.to_sym)

      allincludes[new_includes.to_sym] = {}
    elsif new_includes.is_a?(Array)
      new_includes.each do |inc|
        merge_includes allincludes, inc
      end
    else
      new_includes.each do |key, value|
        merge_includes allincludes, key
        merge_includes allincludes[key], value
      end
    end
  end

  def find_field(lookups, model_klasses, all_includes)
    return if lookups.empty?

    nested_model_klasses = []
    includes = []
    model_klasses.each_with_index do |model_klass, index|
      exposure_klass = model_klass.exposure_class
      next if exposure_klass.nil?

      attribute = exposure_klass.attributes[lookups[0].to_sym]
      unless attribute.present?
        attribute = exposure_klass.attributes[:custom_fields]
        next unless attribute.present?

        merge_includes all_includes[index], attribute.includes
        next
      end


      merge_includes all_includes[index], attribute.includes

      next unless attribute.exposure

      name = attribute.record_attribute == true ? attribute.name.to_sym : attribute.record_attribute.to_sym

      unless all_includes[index].include?(name)
        all_includes[index][name] = {}
      end

      association = model_klass.reflect_on_association(name)
      class_names = if association.polymorphic?
                      model_klass.distinct.pluck("#{name}_type")
                    else
                      [association.class_name]
                    end
      class_names.each do |class_name|
        klass = Object.const_get(class_name)
        nested_model_klasses << klass
        includes << all_includes[index][name]
      end
    end
    return if nested_model_klasses.empty?

    find_field(lookups.slice(1..-1), nested_model_klasses, includes)
  end

  def merge_lookups(all_lookups, new_lookups)
    new_lookups.each do |key, value|
      unless all_lookups.include?(key)
        all_lookups[key] = []
      end
      value.each do |v|
        all_lookups[key].append v
      end
    end
  end

  def handle_variable_lookup(variable_lookup)
    return {} if variable_lookup.nil?
    return {} unless variable_lookup.is_a?(Liquid::VariableLookup)
    return { variable_lookup.name => [] } if variable_lookup.lookups.empty?

    { variable_lookup.name => [variable_lookup.lookups] }
  end

  def handle_variable(variable)
    return {} if variable.nil?
    return {} unless variable.is_a?(Liquid::Variable)

    all_lookups = {}
    merge_lookups all_lookups, handle_filters(variable.filters)
    merge_lookups all_lookups, handle_variable_lookup(variable.name)

    all_lookups
  end

  def handle_filters(filters)
    return {} if filters.nil?
    return {} if filters.empty?

    all_lookups = {}
    filters.each do |filter|
      next if filter.length <= 1

      filter[1].each do |value|
        merge_lookups all_lookups, handle_variable_lookup(value)
      end

      next if filter.length <= 2

      filter[2].each do |_, value|
        merge_lookups all_lookups, handle_variable_lookup(value)
      end
    end

    all_lookups
  end

  def handle_if(node)
    return {} if node.nil?
    return {} unless node.is_a?(Liquid::If) || node.is_a?(Liquid::Unless)

    all_lookups = {}

    node.blocks.each do |blk|
      merge_lookups all_lookups, handle_variable_lookup(blk.left)
      merge_lookups all_lookups, handle_variable_lookup(blk.right)
      merge_lookups all_lookups, handle_document(blk.attachment)
    end

    all_lookups
  end

  def handle_for(node)
    return {} if node.nil?
    return {} unless node.is_a?(Liquid::For)

    all_lookups = {}

    collection_lookups = handle_variable_lookup(node.collection_name)
    merge_lookups all_lookups, collection_lookups
    merge_lookups all_lookups, handle_variable_lookup(node.from)
    merge_lookups all_lookups, handle_variable_lookup(node.limit)

    block_lookups = {}
    node.nodelist.each do |block_node|
      merge_lookups block_lookups, handle_document(block_node)
    end

    if block_lookups.include?(node.variable_name)
      collection_lookups.each do |key, value|
        if value.empty?
          block_lookups[node.variable_name].each do |lookup|
            merge_lookups block_lookups, { key => [lookup] }
          end
        else
          value.each do |v|
            block_lookups[node.variable_name].each do |lookup|
              merge_lookups block_lookups, { key => [v + lookup] }
            end
          end
        end
      end
      block_lookups.delete node.variable_name
    end

    merge_lookups all_lookups, block_lookups

    all_lookups
  end

  def handle_assign(node)
    return {} if node.nil?
    return {} unless node.is_a?(Liquid::Assign)

    all_lookups = {}

    merge_lookups all_lookups, handle_variable(node.from)

    node.nodelist.each do |block_node|
      merge_lookups all_lookups, handle_document(block_node)
    end

    all_lookups
  end

  def handle_case(node)
    return {} if node.nil?
    return {} unless node.is_a?(Liquid::Case)

    all_lookups = {}

    merge_lookups all_lookups, handle_variable_lookup(node.left)

    node.blocks.each do |blk|
      merge_lookups all_lookups, handle_variable_lookup(blk.right)
      merge_lookups all_lookups, handle_document(blk.attachment)
    end

    all_lookups
  end

  def handle_cycle(node)
    return {} if node.nil?
    return {} unless node.is_a?(Liquid::Cycle)

    all_lookups = {}

    node.variables.each do |variable_lookup|
      merge_lookups all_lookups, handle_variable_lookup(variable_lookup)
    end

    all_lookups
  end

  def handle_include(node)
    return {} if node.nil?
    return {} unless node.is_a?(Liquid::Include)

    all_lookups = {}

    merge_lookups all_lookups, handle_variable_lookup(node.template_name_expr)
    merge_lookups all_lookups, handle_variable_lookup(node.variable_name_expr)

    all_lookups
  end

  def handle_document(document)
    return {} if document.nil?
    return {} unless document.is_a?(Liquid::Document) || document.is_a?(Liquid::BlockBody)
    return {} if document.nodelist.empty?

    all_lookups = {}

    document.nodelist.each do |node|
      if node.is_a?(Liquid::Variable)
        merge_lookups all_lookups, handle_variable(node)
      elsif node.is_a?(Liquid::Unless)
        # Liquid::Unless is on inherits of Liquid::If. So, same parsing can be used.
        merge_lookups all_lookups, handle_if(node)
      elsif node.is_a?(Liquid::If)
        merge_lookups all_lookups, handle_if(node)
      elsif node.is_a?(Liquid::For)
        merge_lookups all_lookups, handle_for(node)
      elsif node.is_a?(Liquid::Assign)
        merge_lookups all_lookups, handle_assign(node)
      elsif node.is_a?(Liquid::Case)
        merge_lookups all_lookups, handle_case(node)
      elsif node.is_a?(Liquid::Cycle)
        merge_lookups all_lookups, handle_cycle(node)
      elsif node.is_a?(Liquid::Include)
        merge_lookups all_lookups, handle_include(node)
      end
    end

    all_lookups
  end

  def parse
    includes = {}
    all_lookups = {}
    templates.each do |template|
      root = Liquid::Template.parse(template).root
      merge_lookups all_lookups, handle_document(root)
    end

    return {} unless all_lookups.include?(lookup_key)

    all_lookups[lookup_key].each do |lookups|
      find_field(lookups, [model_klass], [includes])
    end

    includes
  end
end
