class PurchaseRequestFormsController < BaseControllers::WebBase

  layout 'trailblazers'

  def show
    endpoint Docs::I2P::PurchaseRequests::Ops::Show
  end

  def create
    endpoint Docs::I2P::PurchaseRequests::Ops::Create
  end

  def create_and_submit
    @op = Docs::I2P::PurchaseRequests::Ops::CreateAndSubmit.({params: params.to_unsafe_h, current_user: current_user})
    respond_to do |format|
      format.json {}
    end
  end

  def update
    endpoint Docs::I2P::PurchaseRequests::Ops::Update
  end

  def save_and_submit
    @op = Docs::I2P::PurchaseRequests::Ops::SaveAndSubmit.({params: params.to_unsafe_h, current_user: current_user})
    respond_to do |format|
      format.json {}
    end
  end
end