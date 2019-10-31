json.merge! JSON.parse yield rescue nil
json.success @result.success?