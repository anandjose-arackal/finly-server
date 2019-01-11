class MakeProcurementModelsSoftDeletable < ActiveRecord::Migration[4.2]
  def change
    add_column :inventory_line_items, :is_deleted, :boolean, default: false, null: false
    add_column :tax_rates, :is_deleted, :boolean, default: false, null: false
    add_column :procurements, :is_deleted, :boolean, default: false, null: false
    add_column :purchase_orders, :is_deleted, :boolean, default: false, null: false
    add_column :purchase_order_items, :is_deleted, :boolean, default: false, null: false
    add_column :bill_of_supplies, :is_deleted, :boolean, default: false, null: false
    add_column :procurement_comments, :is_deleted, :boolean, default: false, null: false
    add_column :delivery_challans, :is_deleted, :boolean, default: false, null: false
    add_column :e_way_bills, :is_deleted, :boolean, default: false, null: false
    add_column :inward_documents, :is_deleted, :boolean, default: false, null: false
    add_column :inward_document_items, :is_deleted, :boolean, default: false, null: false
    add_column :branch_locations, :is_deleted, :boolean, default: false, null: false
    add_column :departments, :is_deleted, :boolean, default: false, null: false
    add_column :procurement_terms, :is_deleted, :boolean, default: false, null: false
    add_column :payment_terms, :is_deleted, :boolean, default: false, null: false


    # running migration code for changing tax to tax rate it
    taxes = [0, 0.1, 0.25, 3, 5, 12, 18, 28]

    companies = Company.all

    companies.each do |company|
      #Create default taxes for all companies
      taxes.each do |tax|
        company.tax_rates.create(name: tax.to_s, rate: tax)
      end


      # Find inventory items and tax_rate id for tax
      company.inventory_line_items.each do |item|
        tax = item.tax

        if tax.present?
          tax_rate_id = company.tax_rates.with_rate(tax).first&.id
        else
          tax_rate_id = company.tax_rates.with_rate(0).first&.id
        end

        item.update(tax_rate_id: tax_rate_id)
      end
    end
  end
end
