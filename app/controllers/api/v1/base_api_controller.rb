class Api::V1::BaseApiController < BaseControllers::ApiBase
  rescue_from NotAuthorizedException, with: :un_authorized

  def un_authorized
    render 'api/v1/shared/failure'
  end

  protected
  def respond(opts={})
    if opts.present?
      if opts[:response] == :failure
        respond_to do |format|
          format.json { render 'api/v1/shared/failure' }
        end
        return
      end
      if opts[:response] == :success
        respond_to do |format|
          format.json { render 'api/v1/shared/success' }
        end
        return
      end
    end
    super(opts)
  end

end
