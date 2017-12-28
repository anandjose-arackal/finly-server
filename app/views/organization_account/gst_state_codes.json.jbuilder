json.codes do
  json.array!(@result) do |state|
    json.id state.id
    json.name "#{state.name} - #{state.state_code}"
  end
end
