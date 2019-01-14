class Api::V0::BaseApiController < BaseControllers::PublicBase
  rescue_from NotAuthorizedException, with: :un_authorized

  def un_authorized
    render 'api/v0/shared/failure'
  end

  protected
  def respond(opts={})
    if opts.present?
      if opts[:response] == :failure
        render 'api/v0/shared/failure'
        return
      end
      if opts[:response] == :success
        render 'api/v0/shared/success'
        return
      end
    end
    super(opts)
  end

end
