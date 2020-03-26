# report user initial
user_initial = @result.report.user.name.split(' ').first[0] + ((@result.report.user.name.split(' ')[1][0] rescue nil) or @result.report.user.name.split(' ').first[1])

# logged in user initial
logged_in_user = @result.user.name.split(' ').first[0] + ((@result.user.name.split(' ')[1][0] rescue nil) or @result.user.name.split(' ').first[1])

json.user_initial logged_in_user || user_initial
json.logged_in_user logged_in_user
json.report_user user_initial

# Report show has new structure, trails and comments are separated.
if !!StringUtils.to_bool(params[:skip_trails])
  report_comments = @result.comments.where(report_comment_action_id: ReportCommentAction.id_for(:report_comment))
else
  report_comments = @result.comments
end

json.comments report_comments do |comment|
  json.report_id comment.report_id
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
