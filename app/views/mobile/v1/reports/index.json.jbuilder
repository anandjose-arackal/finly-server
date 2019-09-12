json.array! @result.paginated_reports do |report|
  json.partial! 'report', report: report, result: @result

  json.tax_rates @result.tax_rates
  json.state_codes @result.gst_state_codes
end