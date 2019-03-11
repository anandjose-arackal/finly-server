json.result do
  json.renewal_alert_periods do
    json.array!(@result.renewal_alert_period) do |period|
      json.id period.id
      json.name period.name 
    end
  end
end