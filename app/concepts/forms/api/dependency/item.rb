class Forms::API::Dependency::Item
  attr_accessor :map, :controlling_field, :dependent_field, :dependency_mappings

  class DependencyMapping

    attr_accessor :controlling_choice, :dependent_required, :dependent_editable, :dependent_visible, :dependent_choices

    def initialize(controlling_choice:, required: false, editable: false, visible: false, choices: nil)
      self.controlling_choice = controlling_choice
      self.dependent_required = required
      self.dependent_editable = editable
      self.dependent_visible = visible
      self.dependent_choices = choices
    end

    def map(user, form, controlling_entity, dependent_entity)
      dependency_choice_mappings_attributes = self.dependent_choices.map do |dependent_choice|
        {
            form_id: form.id,
            company_id: user.company_id,
            controlling_entity: controlling_entity,
            controlling_choice: controlling_entity.choices_provider.find_by_name(controlling_choice, user: user),
            dependent_choice: dependent_entity.choices_provider.find_by_name(dependent_choice, user: user)
        }
      end

      {
          form_id: form.id,
          company_id: user.company_id,
          controlling_choice: controlling_entity.choices_provider.find_by_name(controlling_choice, user: user),
          dependent_required: self.dependent_required,
          dependent_editable: self.dependent_editable,
          dependent_visible: self.dependent_visible,
          has_dependent_choices: dependency_choice_mappings_attributes.present?,
          lazy_load_dependent_choices: (dependency_choice_mappings_attributes.present? and dependency_choice_mappings_attributes.size > 30),
          dependency_choice_mappings_attributes: dependency_choice_mappings_attributes
      }
    end

  end

  def initialize(controlling_field:, dependent_field:, dependency_mappings:)
    self.controlling_field = controlling_field
    self.dependent_field = dependent_field
    self.dependency_mappings = dependency_mappings.map { |mapping| DependencyMapping.new(**mapping) }
  end

  def find_or_create(user, form)
    entities = {}.with_indifferent_access
    form.entities.each { |f| entities[f.field_path] = f }
    dependency = form.dependencies.where(
        controlling_entity_id: entities[controlling_field].id,
        dependent_entity_id: entities[dependent_field].id).first
    return dependency if dependency

    dependency_mapping_attributes = dependency_mappings&.map do |mapping|
      mapping.map(user, form, entities[controlling_field], entities[dependent_field])
    end

    form.dependencies.create(
        {
            form_id: form.id,
            company_id: user.company_id,
            controlling_entity_id: entities[controlling_field].id,
            dependent_entity_id: entities[dependent_field].id,
            dependency_mappings_attributes: dependency_mapping_attributes
        }
    )
  end

end