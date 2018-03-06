json.gst @result.collect_detail.gst
json.pan @result.collect_detail.pan
json.address @result.collect_detail.address
json.pin @result.collect_detail.pin
json.company_logo do
  json.url @result.collect_detail.company_logo&.url
  json.thumb @result.collect_detail.company_logo&.url(:thumb)
end
