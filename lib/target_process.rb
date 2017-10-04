module TargetProcess
  class Handler
    class << self

      def get_card type = "generals", id
        url = URI("https://blubeta.tpondemand.com/api/v1/#{type}/#{id}" )
        request_from_tp(url, "get")
      end

      def get_user_cards id
        cards = []
        url = "https://blubeta.tpondemand.com/api/v1/Assignments/?where=(GeneralUser.id eq #{id})and(Assignable.EntityState.name ne 'Done')and(Assignable.EntityType.name ne 'feature')&take=1000&include=[Assignable[EntityType, Name,EntityState]]"
        response = {"Next" => url}
        while(response["Next"])
          response = request_from_tp(URI(response["Next"]), "get")
          response["Items"].each do |card|
            cards << {
              type: card["Assignable"]["ResourceType"],
              name: card["Assignable"]["Name"],
              id:   card["Assignable"]["Id"]
             }
          end
        end
        cards
      end

      def get_hours user, time
        total = 0.00
        url = "https://blubeta.tpondemand.com/api/v1/Times?where=(User.FirstName eq '#{user.downcase}')and(CreateDate gt '#{time}')&take=1000"
        response = {"Next" => url}
        while(response["Next"])
          response = request_from_tp(URI(response["Next"]), "get")
          response["Items"].each do |entity|
            total += entity["Spent"]
          end
        end
        total.round(2)
      end

      def get_all_hours time
        userTimes = Hash.new(0)
        url = "https://blubeta.tpondemand.com/api/v1/Times?where=(CreateDate gt '#{time}')&take=100"
        response = {"Next" => url}
        while(response["Next"])
          response = request_from_tp(URI(response["Next"]), "get")
          response["Items"].each do |entity|
            userTimes[entity["User"]["FirstName"] + " " + entity["User"]["LastName"]] += entity["Spent"]
          end
        end
        userTimes.sort_by{|k,v| -v}
      end

      def export_time(user, assignable, hours, description)
        url = URI("https://blubeta.tpondemand.com/api/v1/times?") #TODO readd token
        payload = create_time_payload assignable, hours, user, description
        request_from_tp url, "post", payload
      end

      private

      def request_from_tp url, type, payload = {}
        if type == "get"
          req = Net::HTTP::Get.new url
        elsif type == "post"
          req = Net::HTTP::Post.new url
          req.body = payload.to_json
        else
          p "You didn't specify a request type"
        end
        req.basic_auth
        req["Content-Type"] = "application/json"
        req['Accept'] = "application/json"
        res = Net::HTTP.start(url.hostname, url.port, :use_ssl => url.scheme == 'https') { |http| http.request(req) }
        JSON.parse res.body
      end

      def create_time_payload assignable, hours, user, description
        {
          "Assignable": {
          	"Id": assignable
          },
          "Remain": 0.0,
          "User": {
          	"Id": user
           },
          "Spent": hours,
          "Description": description
        }
      end

    end
  end
end
