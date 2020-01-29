class Notifications::Mailers::Documents < Notifications::Mailer

  schema do
    params do
      required(:task).filled
    end
  end

  recipients do |user, params|
    params[:task].recipients
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