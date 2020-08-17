class Masters::Schema::Ops::MigrationRunner < Transactions::API
  include Transactions::BackgroundWorker

  def self.Build()
    Transactions::Task.build id: "schema.migrate" do |context, flow_options, circuit_options|
      result = Masters::Schema::Ops::MigrationRunner.(params: {id: context[:model].id})
      return merge_result(context, result) unless result.success?

      true
    end
  end

  skip_user_authorization!

  step Model(MasterSchema, :find_by_uuid)
  step :init_record_model_class
  step :create_table
  step :sync_attributes
  pass :set_last_migration_at
  pass :clear_record_model_class

  COLUMN_ARGS = {
      index: true
  }

  DEFAULT_COLUMNS = %w(id deleted_at created_at updated_at)

  def init_record_model_class(context, model:, **)
    context[:record_model_class] = model.record_model_class
  end

  def create_table(context, record_model_class:, **)
    return true if record_model_class.table_exists?

    ActiveRecord::Migration.create_table record_model_class.table_name do |t|
      t.datetime :deleted_at, index: true

      t.timestamps index: true, null: false
    end

    true
  end

  def sync_attributes(context, model:, record_model_class:, **)
    existing_attributes = record_model_class.columns.map { |col| col.name }
    required_attributes = {}
    system_attributes = []
    model.entities.each do |entity|
      system_attributes << entity.entity_key if entity.system_entity

      required_attributes[entity.entity_key] = entity.database_type
    end

    attr_to_add = required_attributes.keys - existing_attributes - DEFAULT_COLUMNS
    attr_to_remove = existing_attributes - required_attributes.keys - system_attributes - DEFAULT_COLUMNS

    attr_to_add.each do |attr|
      ActiveRecord::Migration.add_column record_model_class.table_name, attr, required_attributes[attr], COLUMN_ARGS
    end

    # Pre-migration: Many masters have additional attributes. Skipping deleting attributes altogether for system masters
    unless model.system_master
      attr_to_remove.each do |attr|
        ActiveRecord::Migration.remove_index record_model_class.table_name, attr
        ActiveRecord::Migration.remove_column record_model_class.table_name, attr
      end
    end

    true
  end

  def set_last_migration_at(context, model:, **)
    model.update(last_migration_at: DateTime.now)
  end

  def clear_record_model_class(context, model:, **)
    model.clear_record_model_class
  end

end