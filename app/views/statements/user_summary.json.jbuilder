json.header_group do
  json.array! @result.generate_header_group
end
json.header_main do
  json.array! @result.generate_header_main
end
json.contents do
  json.array! @result.generate_contents
end