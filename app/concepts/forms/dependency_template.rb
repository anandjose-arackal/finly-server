class Forms::DependencyTemplate < Templates::API

  # Root should return the
  root do
    finder do |context|
      Form.find_by(company_id: context.params[:company_id], klass_name: context.template.klass_name)
    end

    association :choice_dependencies do |exec_context|
      matcher do |template, record|
        record.dependency_id == template.dependency_id
      end

      clone do |choice_context|
        set :company_id, exec_context.params[:company_id]
        set :form, exec_context.root_record
        set :custom, false
        set :is_updated, false
        set :controlling_entity, choice_context.root_record.find_entity(choice_context.template.template_reference[:controlling_entity_path])
        set :dependent_entity, choice_context.root_record.find_entity(choice_context.template.template_reference[:dependent_entity_path])
      end
      association :mappings do
        clone do |mapping_context|
          set :dependency, mapping_context.parent
          set :controlling_choice_id, mapping_context.parent.controlling_entity.choices_scope.find_by_name(mapping_context.template.template_reference[:controlling_choice], user: context.params[:user])&.id
          set :dependent_choice_id, mapping_context.parent.dependent_entity.choices_scope.find_by_name(mapping_context.template.template_reference[:dependent_choice], user: context.params[:user])&.id
        end
      end
    end
  end

end