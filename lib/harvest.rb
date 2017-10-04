module Harvest
  class Handler
    class << self

      def export_time(user, project, description, hours, task_id)
        url = URI("https://api.harvestapp.com/v2/time_entries?user_id=#{user}&project_id=#{project}&task_id=#{task_id}&spent_date=#{Time.now.strftime("%Y-%m-%d")}&hours=#{hours}&notes=#{description}")
        request_from_harvest(url, "post")
      end

      private

      def request_from_harvest url, type, payload = {}
        if type == "get"
          req = Net::HTTP::Get.new url
        elsif type == "post"
          req = Net::HTTP::Post.new url
          req.body = payload.to_json
        else
          p "You didn't specify a request type"
        end
        req["Harvest-Account-ID"] = "269601"
        req["Content-Type"] = "application/json"
        req['Accept'] = "application/json"
        res = Net::HTTP.start(url.hostname, url.port, :use_ssl => url.scheme == 'https') { |http| http.request(req) }
        JSON.parse res.body
      end

    end
  end
end
