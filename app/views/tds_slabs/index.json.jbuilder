json.array!(@result.tds_slabs) do |tds_slab|
  json.id tds_slab.id
  json.name tds_slab.name
  json.tds tds_slab.tds
end