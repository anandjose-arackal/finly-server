class Forms::DependencyTemplate < Templates::API

  # Root should return the
  root do |params|
    Form.where(company_id: params[:company_id], klass_name: template.klass_name).first
  end

  association :choice_dependencies do |exec_context|
    matcher do |template, record|
      record.dependency_id == template.dependency_id
    end

    set :company_id, exec_context[:company_id]
    set :form, exec_context[:root_record]
    set :custom, false
    set :is_updated, false
    set :controlling_entity, -> (context) { context[:root_record].find_entity(context[:template].template_reference[:controlling_entity_path]) }
    set :dependent_entity, -> (context) { context[:root_record].find_entity(context[:template].template_reference[:dependent_entity_path]) }
    association :mappings do |mapping_context|
      set :dependency, -> (context) { context[:parent] }
      set :controlling_choice_id, -> (context) do
        context[:parent].controlling_entity.choices_scope.find_by_name(context[:template].template_reference[:controlling_choice], user: context[:user])&.id
      end
      set :dependent_choice_id, -> (context) do
        context[:parent].dependent_entity.choices_scope.find_by_name(context[:template].template_reference[:dependent_choice], user: context[:user])&.id
      end
    end
  end

end