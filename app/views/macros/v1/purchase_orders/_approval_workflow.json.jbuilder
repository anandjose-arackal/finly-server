json.level do
  json.number dlrm.level.level_number
  json.name dlrm.level.name
end
json.action_taken dlrm.action_id.present?
json.action dlrm.action
json.approved dlrm.action_id == TrailAction.id_for(:approve)
if dlrm.action_taken_by.present?
  json.action_taken_by do
    json.id dlrm.action_taken_by&.id
    json.email dlrm.action_taken_by&.email
    json.mobile_number dlrm.action_taken_by&.mobile_number
  end
else
  json.action_taken_by(nil)
end
json.tat dlrm.tat
