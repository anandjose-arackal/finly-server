class MigrateToParanoid < ActiveRecord::Migration[5.2]
  def change
    # To translate from is_deleted to deleted_at for paranoia gem
    models = ApplicationRecord.descendants
    models.each do |model|
      if model <= SoftDeletable and !(model.column_names.include?("deleted_at"))
        model.migrate_to_paranoid
      end
    end
  end
end
