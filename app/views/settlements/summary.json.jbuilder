json.data do
  json.merge! @result.balances
  json.actions @result.actions
end
