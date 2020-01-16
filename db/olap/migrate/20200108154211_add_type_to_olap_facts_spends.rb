class AddTypeToOlapFactsSpends < ActiveRecord::Migration[5.2]
  def change
    add_column :olap_facts_spends, :type, :string, index: true
  end
end
