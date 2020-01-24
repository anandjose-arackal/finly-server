json.count @result.export_jobs.count
json.data do
  json.array! @result.paginated_export_jobs # @result.paginated_export_jobs
end