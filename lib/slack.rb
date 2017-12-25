module Slack
  class Messenger
    class << self

      def send_message message, channel, attachments = []
        url = _generate_message_uri message, channel, attachments
        Net::HTTP.get(url)
      end

      def send_file file, file_type, file_name, channel, attachments = []
        url = _generate_file_uri channel, attachments
        file_to_send = file.force_encoding("ISO-8859-1").encode("UTF-8")
        p file_to_send
        req = Net::HTTP::Post.new(url)
        req.body = {content: file_to_send, filename: "report.zip", filetype: "zip", channels: channel}.to_json
        res = Net::HTTP.start(url.hostname, url.port) do |http|
          http.request(req)
        end
        res.body
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

      def _generate_file_uri channel, attachments
        URI.parse(URI.encode(
        "https://slack.com/api/files.upload?"+
        "token=#{ENV["slack_auth_token"]}"+
        "channels=#{channel}&"+
        "attachments=#{attachments.to_json}"))
      end

    end
  end
end
