class Masters::Vendors::AutoComplete < AutoComplete::API

  resolver Masters::Vendors::Resolver
  json do |context, record|
    {
        id: record.id,
        name: "#{record.vendor_id} - #{record.business_name}"
    }
  end
  search_key :business_name_or_trade_name_or_vendor_id_cont

end