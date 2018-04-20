json.array! @booking_types do |bt|
  json.extract! bt, :id, :name
end