class AddGrnNumberToInwardDocument < ActiveRecord::Migration[5.2]
  def change
    Purpose.seed_data
    Seedable.refresh_all_caches

    add_column :inward_documents, :grn_number, :string, index: true
    company_ids = InwardDocument.all.pluck(:company_id).uniq
    company_ids.each do |id|
      InwardDocument.where(company_id: id).reorder(created_at: :asc).all.each do |inward_document|
        inward_document.save
      end
    end

    add_column :items, :item_number, :string, index: true
    company_ids = Item.all.pluck(:company_id).uniq
    company_ids.each do |id|
      Item.where(company_id: id).reorder(created_at: :asc).all.each do |item|
        item.save
      end
    end

    add_column :rate_contracts, :rate_contract_number, :string, index: true
    company_ids = RateContract.all.pluck(:company_id).uniq
    company_ids.each do |id|
      RateContract.where(company_id: id).reorder(created_at: :asc).all.each do |rate_contract|
        rate_contract.save
      end
    end
  end
end
