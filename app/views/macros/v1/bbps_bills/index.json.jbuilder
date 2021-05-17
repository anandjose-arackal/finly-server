#includes = [
#
#]
json.data do
  json.array! @op['model.records'] do |record|
    json.partial! 'bbps_bill', record: record
  end
end