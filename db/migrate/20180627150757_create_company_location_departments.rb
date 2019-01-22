class CreateCompanyLocationDepartments < ActiveRecord::Migration[4.2]
  def change
    create_table :company_location_departments do |t|
      t.references :branch_location, index: true, foreign_key: true, null: false
      t.references :company_department, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    UserRole.seed_data
  end
end
