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

end