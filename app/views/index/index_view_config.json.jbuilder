json.data do
  json.index_config @index_config[:config]
  json.system_views @view_config[:system_views]
  json.user_views @view_config[:user_views]
end