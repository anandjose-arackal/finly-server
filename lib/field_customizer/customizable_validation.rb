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
      def field_customization_key(key)
        FIELD_CUSTOMIZER_KEY_MAP[key] = self.name
      end

      def customizable_validate(field, options = {})
        unless defined?(customizable_options)
          include FieldCustomizer::CustomizableValidation::InstanceMethods

          mattr_accessor :customizable_options, instance_accessor: false
          mattr_accessor :skip_customizable_validation
          self.customizable_options = {}

          after_save {self.skip_customizable_validation=nil}
        end

        return if customizable_options[field].present?

        options = DEFAULT_OPTIONS.merge(options)
        if options[:scope].blank?
          raise "ActsAsCustomizable: Scope not defined for ActsAsCustomizable for field #{field} in class #{self.class.name}"
        end

        customizable_options[field] = options

        validation_method_name = "field_customizer_#{field}"
        validate validation_method_name

        define_method validation_method_name do
          return if self.skip_customizable_validation
          options = self.class.field_configuration_for(field, field_configuration_scope_for(field))
          return unless options
          condition = options[:if]
          if condition.present?
            if condition.is_a?(Symbol)
              unless self.respond_to?(condition)
                raise "Method #{condition} not found for class #{self.class.name}"
              end
              return unless self.send(condition)
            else
              return unless condition
            end
          end
          return unless options[:enabled]
          return unless options[:presence]
          if self.send(field).blank?
            self.errors.add field, 'cannot be blank'
          end
        end
      end

      def field_configuration_for(field, scoped_attr)
        options = customizable_options[field]
        return nil if options.blank?
        return nil if scoped_attr.nil?
        customization_options = FieldCustomization.with_scope(scoped_attr).with_class_name(self.name).with_field_name(field)
        return options.merge customization_options&.first.options if customization_options.present?
        options
      end
    end

    module InstanceMethods
      def field_configuration_scope_for(field)
        options = self.class.customizable_options[field]
        scope = options[:scope]

        unless scope.is_a?(Array)
          scope = [scope]
        end

        scoped_attr = self
        scope.each do |attr|
          unless scoped_attr.respond_to?(attr)
            raise "ActsAsCustomizable: Attribute #{attr} not found for field #{field} in class #{scoped_attr.class.name}"
          end
          scoped_attr = scoped_attr.send(attr)
        end
        scoped_attr
      end
    end
  end
end