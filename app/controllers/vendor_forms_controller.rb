class VendorFormsController < BaseControllers::WebBase

  layout 'trailblazers'

  def show
    endpoint Docs::P2P::Vendors::Ops::Show
  end

  def create
    endpoint Docs::P2P::Vendors::Ops::Create
  end

  def create_and_submit
    endpoint Docs::P2P::Vendors::Ops::CreateAndSubmit
  end

  def update
    endpoint Docs::P2P::Vendors::Ops::Update
  end

  def submit
    endpoint Docs::P2P::Vendors::Ops::Submit
  end

    # def resolve_layout
    #   if ["create", "update"].include?(action_name)
    #     'trailblazers'
    #   else
    #     'application'
    #   end
    # end
end