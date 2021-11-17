ImportJobs::Router.draw do
  route 'forms.*', Forms::Import::Job

  scope 'templates' do
    route 'forms.*', Forms::Import::Template
  end
end
