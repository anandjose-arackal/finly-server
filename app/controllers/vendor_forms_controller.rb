# Controller & Routes for the same to be migrated to VendorsController after the rollout has been done for all customers
class VendorFormsController < BaseControllers::WebBase

  layout 'trailblazers'

  def show
    endpoint Docs::P2P::Vendors::Ops::Show
  end

  def create
    endpoint Docs::P2P::Vendors::Ops::Create
  end

  def create_and_submit
    @op = Docs::P2P::Vendors::Ops::CreateAndSubmit.({params: params.to_unsafe_h, current_user: current_user})
    respond_to do |format|
      format.json {}
    end
  end

  def update
    endpoint Docs::P2P::Vendors::Ops::Update
  end

  def submit
    endpoint Docs::P2P::Vendors::Ops::Submit
      # @op = Docs::P2P::Vendors::Ops::UpdateAndSubmit.({params: params.to_unsafe_h, current_user: current_user})
      # respond_to do |format|
      #   format.json {}
      # end
  end
end