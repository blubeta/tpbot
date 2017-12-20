class UserController < ApplicationController
  include ActionController::Live

  def index

  end

  def report
    respond_to do |format|
      format.zip { send_data TargetProcess::Handler.generate_report, type: 'application/zip' }
    end
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
