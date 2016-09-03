json.success true
json.data @result.paginated_reports do |report|
  json.partial! 'report', report: report
end