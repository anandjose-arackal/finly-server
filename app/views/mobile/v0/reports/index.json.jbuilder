json.array! @result.paginated_reports do |report|
  json.partial! 'report', report: report, result: @result
end