module Forms::Definitions::Types::AttributeHelpers::Regex

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def consumes_regex!
      @consumes_regex = true
    end

    def consumes_regex?
      !!@consumes_regex
    end
  end

  def self.load_attributes(klass)
    return unless klass.class.consumes_regex?
    return if klass.attributes.nil?
    klass.attributes[:regex] = @regex
  end

end
