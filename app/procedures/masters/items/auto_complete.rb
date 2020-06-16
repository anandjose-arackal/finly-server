class Masters::Items::AutoComplete < AutoComplete::API

  resolver 'items.default'
  json do |context, record|
    {
        id: record.id,
        name: "#{record.item_number} - #{record.description}"
    }
  end
  search_key :item_number_or_description_cont

end