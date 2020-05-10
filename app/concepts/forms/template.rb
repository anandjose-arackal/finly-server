class Forms::Template < Templates::API

  # Root should return the
  root do |params|
    Form.where(company_id: params[:company_id], klass_name: template.klass_name).first
  end

  template :entities do |exec_context|
    matcher do |template, record|
      template.entity_path == record.entity_path
    end

    set :company_id, exec_context[:company_id]
    set :section, exec_context[:parent].section
    set :form, exec_context[:root_record]
    set :parent, exec_context[:parent] if exec_context[:parent].class <=> FormEntity
    association :entities, &templates[:entities]
    association :choices do |choice_context|
      set :company_id, choice_context[:company_id]
    end
  end

  template :rules do |exec_context|
    set :company_id, exec_context[:company_id]
    set :rule_parent, exec_context[:parent]
    set :form, exec_context[:root_record]
  end

  association :sections do |exec_context|
    matcher do |template, record|
      template.section_id == record.section_id
    end

    set :company_id, exec_context[:company_id]
    set :form, exec_context[:root_record]
    association :entities, condition: ->(entity) { entity.parent.blank? }, &templates[:entities]
  end

  association :conditions do |exec_context|
    matcher do |template, record|
      record.condition_id == template.condition_id
    end

    set :company_id, exec_context[:company_id]
    set :form, exec_context[:root_record]
    association :rules, &templates[:rules]
    association :actions do |action_context|
      set :company_id, action_context[:company_id]
      set :form, action_context[:root_record]
    end
  end

  association :validations do |exec_context|
    matcher do |template, record|
      record.validation_id == template.validation_id
    end

    set :company_id, exec_context[:company_id]
    set :form, exec_context[:root_record]
    association :rules, &templates[:rules]
  end

end