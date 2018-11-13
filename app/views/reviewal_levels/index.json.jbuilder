json.array! @result.reviewal_levels do |level|
  json.merge! level.attributes
  json.reviewers do
    json.array!level.level_reviewer_mappings.non_deleted do |mapping|
      json.extract! mapping, :id, :threshold, :exception

      json.reviewer_details mapping.reviewer.as_json
    end
  end
end