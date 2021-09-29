json.data do
  json.array! @op['model.records'] do |record|
    json.partial! 'report_processor_group', record: record
  end
end