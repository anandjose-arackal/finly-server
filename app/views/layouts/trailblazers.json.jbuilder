json.merge! JSON.parse yield rescue nil
json.success @op.success?
json.errors @op.errors
