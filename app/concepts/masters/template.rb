# Configuration for Synchronization of Simple Masters using Templates::API
class Masters::Template < Templates::API

  root do
    finder do |finder_context, template|
      MasterSchema.find_by(company_id: finder_context.params[:company_id], master_key: template.master_key)
    end

    clone do |root_builder_context|
      set :company_id, root_builder_context.params[:company_id]
    end

    association :entities do
      matcher do |template, record|
        template.entity_key == record.entity_key
      end

      clone do |builder_context|
        set :company_id, builder_context.params[:company_id]
        set :master_schema, builder_context.root_record
      end

      # Since choices does not have finder or matcher defined,
      # it will not support differential sync.
      # It will only be generated when the entity is created
      association :choices do
        clone do |ch_builder_context|
          set :company_id, ch_builder_context.params[:company_id]
        end
      end
    end
  end
end