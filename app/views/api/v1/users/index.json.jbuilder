json.array! @result.paginated_team do |user|
  json.partial! 'user', user: user
end