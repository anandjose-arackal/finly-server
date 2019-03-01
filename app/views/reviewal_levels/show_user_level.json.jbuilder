json.user_details do
  json.merge! @result.target_user.as_json
end

json.levels do
  json.array! @result.levels_data do |data|

    lurms = data[:level].lurms.with_user_id(@result.target_user.id)
    json.original do
      json.level_number data[:level_number]
      json.id data[:id]
      json.overridden lurms.present?
      json.name data[:level]&.name

      json.reviewers do
        json.array! data[:lrms] do |lrm|
          json.name lrm.reviewer&.name
          json.email lrm.reviewer&.email
          json.threshold lrm.threshold
          json.exception lrm.exception
        end
      end
    end
    if lurms.present?
      json.overridden do
        json.level_number data[:level_number]
        json.name data[:level]&.name
        json.id data[:id]

        json.reviewers do 

          json.array! lurms do |lurm|
            json.level_user_reviewer_mapping_id lurm.id
            json.name lurm.reviewer&.name
            json.email lurm.reviewer&.email
            json.threshold lurm.threshold
            json.exception lurm.exception
          end
        end
      end
    end
  end
end
