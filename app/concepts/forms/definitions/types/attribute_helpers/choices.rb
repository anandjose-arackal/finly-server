module Forms::Definitions::Types::AttributeHelpers::Choices

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def consumes_choices!
      @consumes_choices = true
    end

    def consumes_choices?
      !!@consumes_choices
    end
  end

  def choices
    choices = attributes[:choices]
    return choices if choices.present?
    return [] if attributes[:enum].blank?

    klass_name, method = attributes[:enum]
    choices_from_enum klass_name, method
  end

  def choices_from_enum(klass_name, method)
    klass = Object.const_get(klass_name)
    return unless klass.present?
    return unless method.present?

    values = klass.send(method)
    return unless values.present?

    attributes[:choices] += values.map {|name, value| {name: name, value: value}}
  end

  def self.load_attributes(klass)
    return if klass.nil?

    attributes = klass.attributes
    return if attributes.nil?
    return attributes.except(:choices) unless klass.class.consumes_choices?

    attributes[:choices] = [] if attributes[:choices].nil?


  end

end
