class Forms::API::ChoiceDependency
  include DynamicAttributes

  instance_attr :dependency_id
  instance_attr :can_be_updated, default: false
  instance_attr :entity_path
  instance_attr :controlling_entity_path
  instance_attr :mappings, default: []

  def initialize(params, &block)
    params.each_pair do |key, value|
      self.send("#{key}=", value)
    end
    instance_eval &block
  end

  def dependency(controlling_choice, values)
    mappings << Mapping.new(controlling_choice, values)
  end

  def sync(user, form_model)
    return if form_model.dependencies.select {|d| d.dependency_id == self.dependency_id.to_s}.present?

    form_entity = form_model.entities.select {|entity| entity.entity_path == self.entity_path.to_s}.first
    controlling_entity = form_model.entities.select {|entity| entity.entity_path == self.controlling_entity_path.to_s}.first

    dependency = form_model.dependencies.new(
        {
            company_id: user.company_id,
            form: form_model,
            form_entity: form_entity,
            controlling_entity: controlling_entity,
            dependency_id: self.dependency_id,
            custom: false,
            is_updated: false,
            can_be_updated: self.can_be_updated
        }
    )

    mappings.each do |mapping|
      mapping.build(user, form_model, dependency, form_entity, controlling_entity)
    end
    dependency.save
  end

  class Forms::API::ChoiceDependency::Mapping

    attr_accessor :dependency, :controlling_choice, :values

    def initialize(controlling_choice, values)
      self.controlling_choice = controlling_choice
      self.values = values
      self.values = [values] unless values.respond_to?(:each)
    end

    def build(user, form_model, choice_dependency, form_entity, controlling_entity)
      controlling_choice_id = controlling_entity.choices_scope.find_by_name(controlling_choice, user: user)&.id
      rule = choice_dependency.rules.new(
          company_id: user.company_id,
          form: form_model,
          entity_path: controlling_entity.entity_path,
          predicate: 'eq',
          rule_type_id: FormRuleType.id_for(:value),
          match_value: controlling_choice_id
      )
      values.each do |value|
        choice_dependency.mappings.new(
            dependency: choice_dependency,
            form_rule: rule,
            form_entity_choice_id: form_entity.choices_scope.find_by_name(value, user: user)&.id
        )
      end
    end

  end

end