class Forms::DSL::Entity::Contract

  module DSL
    extend ActiveSupport::Concern

    class_methods do
      def contract(&block)
        @contract = Forms::DSL::Entity::Contract.build(&block) if block_given?
        @contract ||= Forms::DSL::Entity::Contract.build
      end
    end
  end

  def self.build(&block)
    Class.new(Dry::Validation::Contract) do
      params do
        required(:section).filled
        required(:field_key).filled
        required(:field_path).filled
        required(:label).filled
        required(:placeholder).filled
        optional(:hint)
        required(:field_type).filled
        optional(:default_value)
        required(:editable).value(:bool?)
        required(:required).value(:bool?)
        optional(:active).filled(:bool?)
        optional(:unique).filled(:bool?)
        optional(:visible).filled(:bool?)
        optional(:multiple).filled(:bool?)
        optional(:position).filled(:int?)
        optional(:custom_field).filled(:bool?)
        optional(:dependent).filled(:bool?)
        optional(:conditional_required).filled(:bool?)
        optional(:can_visible_be_changed).filled(:bool?)
        optional(:can_editable_be_changed).filled(:bool?)
        optional(:can_required_be_changed).filled(:bool?)
        optional(:can_uniqueness_be_changed).filled(:bool?)
        optional(:can_be_disabled).filled(:bool?)
        optional(:can_label_be_renamed).filled(:bool?)
        optional(:can_not_be_hidden).filled(:bool?)
        optional(:can_be_filtered).filled(:bool?)
        optional(:can_choices_be_changed).filled(:bool?)
        optional(:show_in_bulk_import).filled(:bool?)
        optional(:allow_sort_in_filter).filled(:bool?)
        optional(:allow_clearing_default_value).filled(:bool?)

        optional(:choices).array do
          hash do
            optional(:id)
            required(:value).filled
            required(:position).value(:int?)
            required(:active).value(:bool?)
          end
        end
        required(:options) do
          hash do
            instance_exec &block if block_given?
          end
        end
      end
    end
  end
end
