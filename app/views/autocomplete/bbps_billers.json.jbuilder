json.array!(@result.bbps_billers) do |bbps_biller|
  json.id bbps_biller.id
  json.name bbps_biller.biller_name
end