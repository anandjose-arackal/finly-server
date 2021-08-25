DataCards::Router.draw do

  scope "forms" do
    route "*" do
      to DataCards::Adapters::Forms
    end
  end

  scope "masters" do
    route "*" do
      to DataCards::Adapters::Masters
    end
  end

  route "users" do
    to DataCards::Adapters::Users
  end

end