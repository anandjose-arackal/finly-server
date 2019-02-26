json.table_headers do
  json.array! @result.levels_data do |data|
    json.level_number data[:level_number]
    json.name data[:level]&.name
  end
end

debugger
json.result do
  json.array! @result.paginated_users do |user|
    json.user_details do
      json.merge! user.as_json
    end

    json.levels do
      json.array! @result.levels_data do |data|
        json.level_number data[:level_number]
        json.id data[:id]

        lurms = data[:level].lurms.with_user_id(user.id)

        json.overridden lurms.present?

        json.reviewers do 
          if lurms.present?
            json.array! lurms do |lurm|
              json.level_user_reviewer_mapping_id lurm.id
              json.name lurm.reviewer&.name
              json.threshold lurm.threshold
              json.exception lurm.exception
            end
          else
            json.array! data[:lrms] do |lrm|
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