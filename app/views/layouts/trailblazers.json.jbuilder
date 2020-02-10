json.merge! JSON.parse yield rescue nil
json.success @op.success?
json.messages @op.messages