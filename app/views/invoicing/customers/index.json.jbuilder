# ar = [
#     {id: 1, name: 'Ramesh Narayan', phone_number: '7406032047', email: 'ramesh.narayan@grr.la', company: {name: 'XX Co'}},
#     {id: 2, name: 'Ramesh Narayan', phone_number: '7406032047', email: 'ramesh.narayan@grr.la', company: {name: 'XX Co'}},
#     {id: 3, name: 'Ramesh Narayan', phone_number: '7406032047', email: 'ramesh.narayan@grr.la', company: {name: 'XX Co'}},
#     {id: 4, name: 'Ramesh Narayan', phone_number: '7406032047', email: 'ramesh.narayan@grr.la', company: {name: 'XX Co'}},
#     {id: 5, name: 'Ramesh Narayan', phone_number: '7406032047', email: 'ramesh.narayan@grr.la', company: {name: 'XX Co'}},
#     {id: 6, name: 'Ramesh Narayan', phone_number: '7406032047', email: 'ramesh.narayan@grr.la', company: {name: 'XX Co'}}
# ]
#
# json.array! ar

json.array!(@result.customers) do |customer|
  json.id customer.id
  json.name customer.name
  json.mobile_number customer.mobile_number
  json.email customer.email
  json.company do
    json.name customer.company.name
  end
  json.description customer.description
end