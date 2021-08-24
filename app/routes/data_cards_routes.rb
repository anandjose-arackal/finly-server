DataCards::Router.draw do

  scope "forms" do
    route "*" do
      to DataCards::Adapters::Forms
    end
  end

end