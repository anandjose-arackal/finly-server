class Mobile::V0::BaseApiController < BaseControllers::MobileBase
  rescue_from NotAuthorizedException, with: :un_authorized

  def un_authorized
    render 'mobile/v0/shared/failure'
  end

  protected
  def respond(opts={})
    if opts.present?
      if opts[:response] == :failure
        render 'mobile/v0/shared/failure'
        return
      end
      if opts[:response] == :success
        render 'mobile/v0/shared/success'
        return
      end
    end
    super(opts)
  end

end
