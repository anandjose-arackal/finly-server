json.comments @result.comments do |comment|
  json.content comment.generate @result.user
  json.created_at comment.created_at.strftime('%d %b %Y')
  comment_u_id = nil
  comment_u_name = 'System'
  comment_initials = 'S'
  if comment.user.respond_to?(:id, :name)
    comment_u_id = comment.user.id
    comment_u_name = comment.user.name
    comment_initials = comment.user.initials
  end
  json.comment_user_id comment_u_id
  json.comment_user_name comment_u_name
  json.comment_user_initial comment_initials
end