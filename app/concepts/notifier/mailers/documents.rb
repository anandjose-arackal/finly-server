class Notifications::Mailers::Documents < Notifications::Mailer

  # schema do
  #   params do
  #     required(:model).filled
  #     required(:event_name).filled
  #   end
  # end

  recipients do |user, params|
    model = params[:model]
    event = params[:event_name]

    case event
    when :approve, 'approve'
      if model.status_ids(:approved).include?(model.send(:document_status_attribute))
        recipients = [user]
      else
        recipients = model.get_reviewers&.to_a
      end
    when :submit, 'submit', :retracted, 'retracted'
      recipients = [user] + params[:model].get_reviewers&.to_a
    when :rejected, 'rejected'
      recipients = [User.find_by(id: model.send(model.class.document_owner_attribute))]
    when :take_control, 'take_control', :return_control, 'return_control'
      recipients = model.affected_users(:take_control)
    else
      recipients = [user]
    end

    recipients.compact
  end

  class_attr :xyz

  set :model do |user, params|
    params[:model]
  end

  set :event_name do |user, params|
    params[:event_name]
  end

  set :to do |user, params|
    user.email
  end

  set :cc do |user, params|
    params[:cc]
  end

  set :bcc do |user, params|
    params[:bcc]
  end

  set :title do |user, params|
    params[:title] || "Finly Notification"
  end

  set :subject do |user, params|
    params[:subject] || "Notification from Finly"
  end

  set :template, 'default_template'
end