class Forms::API::Entity::Contract

  module DSL
    extend ActiveSupport::Concern

    class_methods do
      def contract(&block)
        @contract = Forms::API::Entity::Contract.build(&block) if block_given?
        @contract ||= Forms::API::Entity::Contract.build
      end
    end
  end

  def self.build(&block)
    Class.new(Dry::Validation::Contract) do
      params do
        required(:section).filled
        required(:entity_key).filled
        required(:entity_path).filled
        required(:label).filled
        required(:placeholder).filled
        optional(:hint)
        required(:entity_type).filled
        optional(:default_value)
        required(:editable).value(:bool?)
        required(:required).value(:bool?)
        optional(:active).filled(:bool?)
        optional(:unique).filled(:bool?)
        optional(:visible).filled(:bool?)
        optional(:position).filled(:int?)
        optional(:custom_field).filled(:bool?)
        optional(:can_visible_be_changed).filled(:bool?)
        optional(:can_editable_be_changed).filled(:bool?)
        optional(:can_required_be_changed).filled(:bool?)
        optional(:can_uniqueness_be_changed).filled(:bool?)
        optional(:can_be_disabled).filled(:bool?)
        optional(:can_label_be_renamed).filled(:bool?)
        optional(:can_choices_be_changed).filled(:bool?)
        optional(:allow_clearing_default_value).filled(:bool?)

        optional(:choices).array do
          hash do
            optional(:id)
            required(:value).filled
            required(:position).value(:int?)
            required(:active).value(:bool?)
          end
        end
        instance_exec &block if block_given?
      end
    end
  end
end
