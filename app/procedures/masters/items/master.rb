class Masters::Items::Master < Masters::API

  model Item
  display_name :description

  schema do
    sequence :item_number, prefix: 'ITEM/', min_length: 6, show_in_lookup: true
    text :description, required: true, show_in_lookup: true, unique: true
    text :hsn_sac
    lookup :category_id, choices_scope: Choices[:lookup].('masters.categories')
  end

end