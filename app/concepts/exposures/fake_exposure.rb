class Exposures::FakeExposure < Exposures::API
  attr_accessor :model_klasses, :all_includes

  def initialize(model_klasses, all_includes)
    self.model_klasses = model_klasses
    self.all_includes = all_includes
  end

  def merge_includes(allincludes, new_includes)
    if new_includes.is_a?(Symbol) || new_includes.is_a?(String)
      unless allincludes.include?(new_includes.to_sym)
        allincludes[new_includes.to_sym] = {}
      end
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

  # use method_missing to capture includes
  def method_missing(m, *args, &block)
    nested_model_klasses = []
    includes = []

    model_klasses.each_with_index do |model_klass, index|
      exposure_klass = model_klass.exposure_class
      attribute = exposure_klass.attributes[m.to_sym]
      next unless attribute.present?

      merge_includes all_includes[index], attribute.includes

      next unless attribute.exposure

      name = attribute.record_attribute == true ? attribute.name : attribute.record_attribute

      unless all_includes[index].include?(name)
        all_includes[index][name] = {}
      end

      association = model_klass.reflect_on_association(name.to_s)
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
    return 1 if nested_model_klasses.empty?

    Exposures::FakeExposure.new(nested_model_klasses, includes)
  end

  # Override Liquid::Drop invokable? method to capture required fields in method_missing method.
  def self.invokable?(method_name)
    true
  end
end
