json.success true
json.data @result.reports do |report|
  json.partial! 'report', report: report
end