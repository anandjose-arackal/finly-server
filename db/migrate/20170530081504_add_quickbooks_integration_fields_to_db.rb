class AddQuickbooksIntegrationFieldsToDb < ActiveRecord::Migration[4.2]
  def change
    # all migrations required for the quickbooks integration will be done here

    #Creating new tables first
    #Creating Quickbooks configurations
    create_table :quickbooks_configurations do |t|
      t.string :quickbooks_payment_type
      t.references :payment_type, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.boolean :auto_import
      t.boolean :auto_export
      t.string :transaction_date_field

      t.timestamps null: false
    end

    # Creating authentication table
    create_table :authentications do |t|
      t.references :user, index: true
      t.string :provider
      t.string :uid
      t.string :name
      t.string :email
      t.string :nickname
      t.string :first_name
      t.string :last_name
      t.string :location
      t.string :description
      t.string :image
      t.string :phone
      t.string :urls
      t.string :token
      t.string :secret
      t.boolean :expires
      t.datetime :expires_at
      t.datetime :refresh_token_at
      t.text :extra

      t.timestamps null: false
    end
    add_foreign_key :authentications, :users

    #Create Quickbooks payment type
    create_table :quickbooks_payment_types do |t|
      t.string :name
      t.references :company, foreign_key: true, index: true

      t.timestamps null: false
    end

    # Create Integrated Users from Quickbooks
    create_table :finly_integrations_users do |t|
      t.string :email
      t.string :name
      t.string :mobile_number
      t.string :external_id
      t.string :external_integration_type
      t.datetime :external_updated_at
      t.boolean :active
      t.text :external_additional_information
      t.references :user, index: true, foreign_key: true
      t.references :company, index: true, foreign_key: true
      t.string :external_user_type

      t.timestamps null: false
    end


    # now all modifications to existing tables to include the respective foreign keys
    # Category table
    add_column :categories, :external_category_type, :string
    add_column :categories, :external_id, :string
    add_column :categories, :external_integration_type, :string
    add_column :categories, :external_updated_at, :datetime
    add_column :categories, :external_additional_information, :text

    # User table
    add_column :users, :external_id, :string
    add_column :users, :external_integration_type, :string
    add_column :users, :external_updated_at, :datetime
    add_column :users, :external_additional_information, :text

    # Company Tags table
    add_column :company_tags, :external_tag_id, :string
    add_column  :company_tags, :external_integration_type, :string
    add_column :company_tags, :external_id, :string
    add_column :company_tags, :external_additional_information, :string
    add_column :company_tags, :external_updated_at, :string


    # Adding to Quickbooks Payment Types
    add_column :quickbooks_payment_types, :external_id, :string
    add_column :quickbooks_payment_types, :external_integration_type, :string
    add_column :quickbooks_payment_types, :external_updated_at, :datetime
    add_column :quickbooks_payment_types, :active, :boolean
    add_column :quickbooks_payment_types, :external_additional_information, :text
    # add_index(:quickbooks_payment_types, [:external_id, :external_integration_type], unique: true)


    # Required indexes
    add_index :categories, :external_updated_at
    add_index :users, :external_updated_at
    add_index(:categories, [:external_id, :external_integration_type], unique: true)
    add_index(:users, [:external_id, :external_integration_type], unique: true)
  end
end
