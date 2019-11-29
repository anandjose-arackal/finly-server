class CreateOlapDimensionsLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :olap_dimensions_locations do |t|
      t.olap_references

      t.timestamps index: true
    end
    create_table :olap_dimensions_cost_centers do |t|
      t.olap_references

      t.timestamps index: true
    end
    create_table :olap_dimensions_policy do |t|
      t.olap_references

      t.timestamps index: true
    end
    create_table :olap_dimensions_item do |t|
      t.olap_references

      t.timestamps index: true
    end
  end
end
