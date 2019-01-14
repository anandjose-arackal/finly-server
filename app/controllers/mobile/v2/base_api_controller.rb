class Mobile::V2::BaseApiController < BaseControllers::PublicBase
  rescue_from NotAuthorizedException, with: :un_authorized

  def un_authorized
    render 'mobile/v1/shared/failure'
  end

  protected
  def respond(opts={})
    if opts.present?
      if opts[:response] == :failure
        respond_to do |format|
          format.json { render 'mobile/v1/shared/failure' }
        end
        return
      end
      if opts[:response] == :success
        respond_to do |format|
          format.json { render 'mobile/v1/shared/success' }
        end
        return
      end
    end
    super(opts)
  end

end
