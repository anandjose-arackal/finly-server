json.codes do
  json.array!(@codes) do |state|
    json.id state.id
    json.name "#{state.name}"
  end
end
