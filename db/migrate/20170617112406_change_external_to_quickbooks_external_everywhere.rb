class ChangeExternalToQuickbooksExternalEverywhere < ActiveRecord::Migration
  def change
    create_table :quickbooks_categories do |t|
      t.references :categories
      t.string :quickbooks_category_type
      t.string :quickbooks_id
      t.string :quickbooks_integration_type
      t.datetime :quickbooks_updated_at
      t.text :quickbooks_additional_information, limit: 16.megabytes - 1

      t.timestamps null: false
    end

    remove_index(:categories, name: 'index_categories_on_external_id_and_external_integration_type')

    remove_column :categories, :external_id, :integer
    remove_column :categories, :external_integration_type, :string
    remove_column :categories, :external_updated_at, :string
    remove_column :categories, :external_additional_information, :text
    remove_column :categories, :external_category_type, :string

    create_table :quickbooks_company_tag do |t|
      t.references :company_tags
      t.string :quickbooks_tag_type
      t.string :quickbooks_integration_type
      t.string :quickbooks_id
      t.text :quickbooks_external_information, limit: 16.megabytes - 1
      t.datetime :quickbooks_updated_at

      t.timestamps null: false
    end

    remove_column :company_tags, :external_id, :integer
    remove_column :company_tags, :external_tag_type, :integer
    remove_column :company_tags, :external_integration_type, :string
    remove_column :company_tags, :external_additional_information, :text
    remove_column :company_tags, :external_updated_at, :string

    # changing external to quickbooks in FinlyIntegrationsUser
    rename_column :finly_integrations_users, :external_id, :quickbooks_id
    rename_column :finly_integrations_users, :external_integration_type, :quickbooks_integration_type
    rename_column :finly_integrations_users, :external_updated_at, :quickbooks_updated_at
    rename_column :finly_integrations_users, :external_user_type, :quickbooks_user_type

    # changing external to quickbooks in QuickbooksPaymentType
    rename_column :quickbooks_payment_types, :external_id, :quickbooks_id
    rename_column :quickbooks_payment_types, :external_integration_type, :quickbooks_integration_type
    rename_column :quickbooks_payment_types, :external_updated_at, :quickbooks_updated_at
    rename_column :quickbooks_payment_types, :external_additional_information, :quickbooks_additional_information
  end
end
