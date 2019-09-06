module Forms::Definitions::DSL

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def model(klass = NoObject)
      @model = klass unless klass == NoObject
      @model
    end

    def field_class(klass = NoObject)
      @field_klass = klass unless klass == NoObject
      @field_klass
    end

    def sections
      @sections ||= []
    end

    def section(name, options = {}, &block)
      sections << Forms::Definitions::Section.new(name, options, &block)
    end

    def functions(&block)
      @functions = block if block_given?
      @functions
    end

    def properties
      return @properties unless @properties.nil?

      @properties = []
      sections.each {|section| @properties += section.properties}
      @properties
    end

    def validations
      return @validations unless @validations.nil?

      @validations = {validate: [], validates: [], validates_with: []}
      sections.each do |section|
        section.validations.each do |type, validation|
          @validations[type] += validation.dup
        end
      end
      @validations
    end
  end


end