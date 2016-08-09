json.success true
json.data @reports do |report|
  json.partial! 'report', report: report
end