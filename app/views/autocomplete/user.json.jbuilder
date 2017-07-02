if @users && !@users.is_a?(BaseOperation::BasePresenter::FailurePresenter)
  json.array!(@users) do |user|
    json.label user.name
    json.value user.id
  end
end