json.transactions do
  json.array!(@result.payments) do |payment|
    json.source_account do
      json.name "Brijesh Yadav"
      json.ifsc "IFSC872598345"
      json.account_number "5612549684621"
    end

    json.amount "5468.132"
    json.note "THis is a note. READ IT!"
    json.date "27-10-2017"
  end
end