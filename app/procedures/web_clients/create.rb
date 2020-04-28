class WebClients::Create < Transactions::API

  schema do
    params do
      required(:version).filled
    end
  end

  skip_user_authorization!

  pass :create_version

  def create_version(context, params:, **)
    WebClient.create version: params[:version]
  end

end