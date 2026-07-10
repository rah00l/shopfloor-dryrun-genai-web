Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get '/health', to: 'health#check'

  root 'chat#index'  # or whatever your chat landing action will be — TBD in W2

  post '/chat/analyze', to: 'chat#analyze'

  get '/sop', to: 'chat#sop_page'
  post '/chat/generate-sop', to: 'chat#generate_sop'

  post '/chat/feedback', to: 'chat#feedback'
end
