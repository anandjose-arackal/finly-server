json.result do 
  json.array! @result.paginated_users do |user|
    json.user_details do
      json.merge! user.as_json
    end

    json.levels do
      json.array! @result.reviewal_levels do |level|
        json.level_number level.level_number
        json.id level.id
        lurms = level.lurms.with_user_id(user.id)

        json.overridden lurms.present?

        json.reviewers do 
          if lurms.present?
            json.array! lurms do |lurm|
              json.name lurm.reviewer&.name
              json.threshold lurm.threshold
              json.exception lurm.exception
            end
          else
            json.array! level.level_reviewer_mappings.non_deleted do |lrm|
              json.name lrm.reviewer&.name
              json.threshold lrm.threshold
              json.exception lrm.exception
            end
          end
        end
      end
    end
  end
end