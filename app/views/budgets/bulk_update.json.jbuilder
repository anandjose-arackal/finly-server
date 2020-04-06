if @result.respond_to?('issues')
  json.issues @result.issues
end
