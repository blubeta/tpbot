class UserController < ApplicationController
  include ActionController::Live

  def report
    respond_to do |format|
      # Slack::Messenger.send_file TargetProcess::Handler.generate_report, "zip", "report.zip", "U5VGFKHUY" #"U5PLF6FL7"
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
