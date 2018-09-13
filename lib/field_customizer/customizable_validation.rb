module FieldCustomizer
  module CustomizableValidation
    DEFAULT_OPTIONS = {
        enabled: true,
        presence: false,
        show_in_pdf: true,
        scope: :company
    }.freeze

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def customizable_validate(field, options = {})
        unless defined?(customizable_options)
          include FieldCustomizer::CustomizableValidation::InstanceMethods

          mattr_accessor :customizable_options, instance_accessor: false
          self.customizable_options = []
        end

        options = DEFAULT_OPTIONS.merge(options)
        if options[:scope].blank?
          raise "ActsAsCustomizable: Scope not defined for ActsAsCustomizable for field #{field} in class #{self.class.name}"
        end

        validation_method_name = "field_customizer_#{field}"
        validate validation_method_name

        define_method validation_method_name do

          scope = options[:scope]
          
          unless scope.is_a?(Array)
            scope = [scope]
          end
          
          scoped_attr = self
          scope.each do |attr|
            unless scoped_attr.methods.include?(attr)
              raise "ActsAsCustomizable: Attribute #{attr} not found for field #{field} in class #{scoped_attr.class.name}"
            end
            scoped_attr = scoped_attr.send(attr)
          end

          customization_options = FieldCustomization.with_scope(scoped_attr).with_class_name(self.class.name).with_field_name(field)
          options = options.merge customization_options&.first.options if customization_options.present?
          return unless options[:enabled]
          return unless options[:presence]
          if self.send(field).blank?
            self.errors.add field, 'cannot be blank'
          end
        end
      end
    end

    module InstanceMethods

    end
  end
end