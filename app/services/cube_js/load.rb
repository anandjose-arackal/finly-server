class CubeJs::Load < CubeJs::Api

  schema do
    params do
      # required(:token).filled
      required(:q).filled
    end
  end

  path 'cubejs-api/v1/load'

  def self.handle_success(result)
    result['data']
  end

end