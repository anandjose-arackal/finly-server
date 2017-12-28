json.codes do
  json.array!(@codes) do |state|
    json.id state.id
    json.name "#{state.name} - #{state.state_code}"
  end
end
