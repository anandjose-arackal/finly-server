# == Schema Information
#
# Table name: form_dependencies
#
#  id                    :bigint           not null
#  company_id            :integer          not null
#  controlling_entity_id :string(255)      not null
#  dependent_entity_id   :string(255)      not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  uuid                  :string(36)       primary key
#  form_id               :string(255)      not null
#

class FormDependency < ApplicationRecord
  include UUIDHelper

  belongs_to :form
  belongs_to :company
  belongs_to :controlling_entity, class_name: 'FormEntity'
  belongs_to :dependent_entity, class_name: 'FormEntity'
  has_many :dependency_mappings, class_name: "FormDependencyMapping"

  accepts_nested_attributes_for :dependency_mappings

  def contract
    dependency = self
    lambda do |*args|
      def dependency_fields(field, path)
        key = path.shift
        value = field.send(key)
        if value.class <= Disposable::Twin::Collection
          fields = []
          value.each do |v|
            fields << dependency_fields(v, path.dup)
          end
          return fields
        elsif value.class <= Reform::Form
          return dependency_fields(value, path.dup)
        else
          return value
        end
      end

      def dependency_validation(dependency)
        controlling_choices = dependency_fields(self, dependency.controlling_entity.field_path.split("/"))
        dependent_choices = dependency_fields(self, dependency.dependent_entity.field_path.split("/"))

        blank_error = false
        scope_choices = false
        available_choices = []
        dependency.dependency_mappings.each do |mapping|
          if [controlling_choices.to_s].include?(mapping.controlling_choice_id)
            # Required
            if mapping.dependent_required
              blank_values = dependent_choices.select { |v| v.blank? }
              blank_error = true if blank_values.present?
            end

            # Scoping Choices
            choices = mapping.dependency_choice_mappings.pluck(:dependent_choice_id)
            if choices.present?
              scope_choices = true
              available_choices += choices
            end
          end
        end

        label = dependency.dependent_entity.label
        if blank_error
          errors.add :base, "#{label} cannot be blank"
        end

        if scope_choices and (dependent_choices.uniq - available_choices.uniq).present?
          errors.add :base, "#{label}: Invalid selection"
        end
      end

      validate -> () { dependency_validation(dependency) }
    end
  end
end
