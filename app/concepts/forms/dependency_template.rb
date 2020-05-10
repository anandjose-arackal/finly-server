class Forms::Template < Templates::API

  # Root should return the
  root do |params|
    Form.where(company_id: params[:company_id], klass_name: template.klass_name).first
  end

  # Todo : WIP
  association :choice_dependencies do |exec_context|
    matcher do |template, record|
      record.dependency_id == template.dependency_id
    end

    set :company_id, exec_context[:company_id]
    set :form, exec_context[:root_record]
    set :custom, false
    set :is_updated, false
    set :form_entity, exec_context[:root_record].find_entity(exec_context[:template].entity_path)
    set :controlling_entity, exec_context[:root_record].find_entity(exec_context[:template].entity_path)
    association :rules do |rules_context|
      set :company_id, exec_context[:company_id]
      set :rule_parent, exec_context[:parent]
      set :form, exec_context[:root_record]
    end
    association :mappings do |mapping_context|
      set :dependency_id, mapping_context[:parent].id
      set :form_rule
    end
  end

end