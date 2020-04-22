class Docs::UtilityBills::Billers::AutoComplete < AutoComplete::API

  resolver 'bbps_billers.default'
  json do |context, record|
    {
        id: record.id,
        name: "#{record.biller_id} - #{record.biller_name}"
    }
  end
  search_key :biller_id_biller_name_or_biller_category_name_biller_alias_name

end