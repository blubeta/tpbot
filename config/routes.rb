Rails.application.routes.draw do
  root 'user#index'
  get  '/report'            => 'user#report'
  post '/api'               => 'api#tp'
  post '/interactions'      => 'api#interactions'
  post '/meme_machine'      => 'api#meme_machine'
end
