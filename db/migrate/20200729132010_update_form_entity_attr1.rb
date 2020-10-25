class UpdateFormEntityAttr1 < ActiveRecord::Migration[5.2]
  def change
    rename_column :form_entities, :custom_field, :system_field
    rename_column :form_entity_validations, :custom, :system_validation

    custom_field_ids = FormEntity.where(system_field: true).pluck(:id)
    system_field_ids = FormEntity.where.not(system_field: true).pluck(:id)

    FormEntity.where(id: custom_field_ids).update_all(system_field: false)
    FormEntity.where(id: system_field_ids).update_all(system_field: true)

  end
end
