class Forms::Template < Templates::API

  # root do |params|
  #   Form.where(company_id: params[:company_id], klass_name: template.klass_name).first
  # end

  template :entities do
    matcher do |template, record|
      template.entity_path == record.entity_path
    end

    clone do |builder_context|
      set :company_id, builder_context.params[:company_id]
      set :section, builder_context.parent.section
      set :form, builder_context.root_record
      set :parent, builder_context.parent if builder_context.parent.class <=> FormEntity
      if builder_context.template.template_reference[:compute_lookup_entity_path].present?
        path = builder_context.template.template_reference[:compute_lookup_entity_path]
        entity = builder_context.root_record.find_entity(path)
        raise "Entity with path : #{path} not found (#{builder_context.template.entity_path})" if entity.nil?
        set :compute_lookup_entity, entity
      end
    end

    association :entities, &templates[:entities]
    association :choices do
      clone do |ch_builder_context|
        set :company_id, ch_builder_context.params[:company_id]
      end
    end
  end

  root do
    finder do |finder_context, template|
      Form.find_by(company_id: finder_context.params[:company_id], klass_name: template.klass_name)
    end

    clone do |root_builder_context|
      set :company_id, root_builder_context.params[:company_id]
    end

    association :sections do
      matcher do |template, record|
        template.section_id == record.section_id
      end

      clone do |builder_context|
        set :company_id, builder_context.params[:company_id]
        set :form, builder_context.root_record
      end

      association :entities, condition: ->(entity) { entity.parent.blank? }, &templates[:entities]
    end

    association :conditions do
      matcher do |template, record|
        record.condition_id == template.condition_id
      end

      clone do |builder_context|
        set :company_id, builder_context.params[:company_id]
        set :form, builder_context.root_record
        path = builder_context.template.template_reference[:reference_key]
        entity = builder_context.root_record.find_entity(path)
        raise "Entity with path : #{path} not found" if entity.nil?

        set :referencable, entity
      end

      association :actions do |action_context|
        clone do
          set :company_id, action_context.params[:company_id]
          set :form, action_context.root_record
        end
      end
    end

    association :validations do
      matcher do |template, record|
        record.validation_id == template.validation_id
      end
      clone do |builder_context|
        set :company_id, builder_context.params[:company_id]
        set :form, builder_context.root_record

        path = builder_context.template.template_reference[:entity_path]
        entity = builder_context.root_record.find_entity(path)
        raise "Entity with path : #{path} not found" if entity.nil?
        set :form_entity, entity
      end
    end
  end
end