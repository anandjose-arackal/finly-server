json.success @result.success?
json.messages @result.messages
json.target_items @result.removed_users
json.conflict @result.conflict
json.conflict_items @result.conflict_messages