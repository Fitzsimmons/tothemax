Tothemax::Application.routes.draw do
  root 'welcome#index'

  resources :results, :only => [:index, :show]
end
