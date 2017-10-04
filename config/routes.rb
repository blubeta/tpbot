Rails.application.routes.draw do
  root 'user#index'
  get '/refresh'            => "user#refresh"
  post '/api'               => 'api#tp'
  post '/interactions'      => 'api#interactions'
  post '/meme_machine'      => 'api#meme_machine'
end
