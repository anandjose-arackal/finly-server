json.array!(@companies) do |company|
  json.extract! company, :name, :id
end
