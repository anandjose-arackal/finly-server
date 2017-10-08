json.array!(@result.beneficiaries) do |beneficiary|
  json.id beneficiary.id
  json.name beneficiary.name
end