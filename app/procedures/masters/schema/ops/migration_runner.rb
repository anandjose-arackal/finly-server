# Every newly created MasterSchema or MasterEntity require a migration to add the necessary table/column in the database against the respective tables. This is handled by the Masters::Schema::Ops::MigrationRunner class.
#
# Masters::Schema::Ops::MigrationRunner is a:
# * Is a Background worker
# * Requires ID of the MasterSchema to execute
# * Ensures the presence of the database table defined in MasterSchema
# * Ensures the presence of all the columns defined in MasterEntity belonging to the MasterSchema
# * Since database migrations are non-locking in MySQL from MySQL 5.5 and above, this should have minimal impact when they are being run.
#
# Reference: https://outline.finly.io/doc/simple-master-ndzgKzXH3N
class Masters::Schema::Ops::MigrationRunner < Transactions::API
  include Transactions::BackgroundWorker

  # Build is a DSL meant to be used to define the migration as a step in the {Transactions::API}
  #
  # @example Defining Build
  #   {Masters::Schema::Ops::MigrationRunner::Build}
  def self.Build()
    Transactions::Task.build id: "schema.migrate" do |context, flow_options, circuit_options|
      result = Masters::Schema::Ops::MigrationRunner.(params: {id: context[:model].id})
      return merge_result(context, result) unless result.success?

      true
    end
  end

  # MigrationRunners do not modify the data based on the incoming input. They identify the difference between the
  # MasterSchema and the database tables and migrate the difference. For this reason, since we have no use for
  # current_user, we skip_use_authorization!
  skip_user_authorization!

  step Model(MasterSchema, :find_by_uuid)
  step :init_record_model_class
  # Create the table unless the table already exists
  step :create_table
  # Identifies missing columns and creates the missing columns
  step :sync_attributes
  # Updates +last_migrated_at+ attribute in MasterSchema to the DateTime.now
  pass :set_last_migration_at


  # This is the default set of arguments passed while creating any column.
  # Index is set as true for all columns in the MasterSchema
  COLUMN_ARGS = {
      index: true
  }


  INTERNAL_COLUMNS = %w(id deleted_at created_at updated_at)

  def init_record_model_class(context, model:, **)
    context[:record_model_class] = model.record_model_class
  end

  def create_table(context, record_model_class:, **)
    unless record_model_class.table_exists?
      ActiveRecord::Migration.create_table record_model_class.table_name do |t|
        t.datetime :deleted_at, index: true

        t.timestamps index: true, null: false
      end
    end

    record_model_class.update(is_table_created: true)
  end

  def sync_attributes(context, model:, record_model_class:, **)
    existing_attributes = record_model_class.columns.map { |col| col.name }
    required_attributes = {}
    system_attributes = []
    model.entities.each do |entity|
      system_attributes << entity.entity_key if entity.system_entity

      required_attributes[entity.entity_key] = entity.database_type
    end

    attr_to_add = required_attributes.keys + INTERNAL_COLUMNS - existing_attributes
    attr_to_remove = existing_attributes - required_attributes.keys - system_attributes - INTERNAL_COLUMNS

    attr_to_add.each do |attr|
      # Todo - move this logic to MasterEntity so it can be overridden if required
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

end