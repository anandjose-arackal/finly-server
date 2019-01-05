class CreateCompanyStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :company_statuses do |t|
      t.string :name, null: false, index: true

      t.timestamps null: false
    end
    CompanyStatus.seed_data
    add_column :companies, :status_id, :integer, references: 'CompanyStatus', default: 1, null: false
    Company.update_all(status_id: CompanyStatus.id_for(:active))
  end
end
