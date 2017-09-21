json.reviewers do
  json.array!(@result.reviewers) do |manager|
    json.id manager.id
    json.name manager.name
  end
end

json.creditors do
  json.array!(@result.creditors) do |manager|
    json.id manager.id
    json.name manager.name
  end
end