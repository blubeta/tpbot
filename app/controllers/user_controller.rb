class UserController < ApplicationController
  include ActionController::Live

  def index
    @users = User.all.pluck(:first_name)
  end

  def refresh
    response.headers['Content-Type'] = 'text/event-stream'
    @sse = SSE.new(response.stream, retry: 1800, event: "update")
  ensure
    @sse.close
  end

  private

  def send_meme
    @sse.write({ name: 'Meme'})
  end
end
