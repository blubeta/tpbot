module Slack
  class Messenger
    class << self

      def send_message message, channel, attachments = []
        url = _generate_message_uri message, channel, attachments
        Net::HTTP.get(url)
      end

      def send_private_message message, response_url, attachments = []
        {
          text: message,
          attachments: attachments
        }
      end

    private

      def _generate_message_uri message, channel, attachments
        URI.parse(URI.encode(
        "https://slack.com/api/chat.postMessage?"+
        "token=#{ENV["slack_auth_token"]}&"+
        "channel=#{channel}&"+
        "text=#{message}&"+
        "attachments=#{attachments.to_json}"))
      end

    end
  end
end
