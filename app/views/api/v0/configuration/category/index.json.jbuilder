json.success true
json.data @result.categories do |category|
  json.extract! category, :id, :name, :active
end