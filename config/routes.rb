Rails.application.routes.draw do
  get '/event-source', to: 'event_source#index'	
  root 'stream#index'
end
