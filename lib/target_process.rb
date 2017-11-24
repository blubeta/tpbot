module TargetProcess
  class Handler
    class << self
      BASE_TP_URL = "https://blubeta.tpondemand.com/api/v1".freeze

      def get_card type = "generals", id, tp_auth_token
        url = URI("#{BASE_TP_URL}/#{type}/#{id}?access_token=#{tp_auth_token}" )
        request_from_tp(url, "get")
      end

      def get_user_cards id, tp_auth_token
        cards = []
        url = "#{BASE_TP_URL}/Assignments/?where=(GeneralUser.id eq #{id})and(Assignable.EntityState.name ne 'Done')and(Assignable.EntityType.name ne 'feature')&take=1000&include=[Assignable[EntityType, Name,EntityState]]&access_token=#{tp_auth_token}"
        response = {"Next" => url}
        while(response["Next"])
          response = request_from_tp(URI(response["Next"] + "&access_token=#{tp_auth_token}"), "get")
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

      def get_hours user, time, tp_auth_token
        total = 0.00
        url = "#{BASE_TP_URL}/Times?where=(User.FirstName eq '#{user.downcase}')and(CreateDate gt '#{time}')&take=1000&access_token=#{tp_auth_token}"
        response = {"Next" => url}
        while(response["Next"])
          response = request_from_tp(URI(response["Next"] + "&access_token=#{tp_auth_token}"), "get")
          response["Items"].each do |entity|
            total += entity["Spent"]
          end
        end
        total.round(2)
      end

      def get_all_hours time, tp_auth_token
        userTimes = Hash.new(0)
        url = "#{BASE_TP_URL}/Times?where=(CreateDate gt '#{time}')&take=1000&access_token=#{tp_auth_token}"
        p url
        response = {"Next" => url}
        while(response["Next"])
          response = request_from_tp(URI(response["Next"] + "&access_token=#{tp_auth_token}"), "get")
          response["Items"].each do |entity|
            userTimes[entity["User"]["FirstName"] + " " + entity["User"]["LastName"]] += entity["Spent"]
          end
        end
        userTimes.sort_by{|k,v| -v}
      end

      def export_time(user, assignable, tp_auth_token, hours, description)
        url = URI("#{BASE_TP_URL}/Times?access_token=#{tp_auth_token}")
        payload = create_time_payload assignable, hours, user, description
        request_from_tp url, "post", payload
      end

      def generate_report
        url = "#{BASE_TP_URL}/Times?where=(Date gte '2017-11-13')and(Date lte '2017-11-19')and(Assignable is not null)&include=[User, Project, Assignable[EntityType, Name], UserStory[Name, Feature, InboundAssignables[EntityType,Name]], Spent, CreateDate]&take=1000"
        auth_token = "&access_token=#{ENV['tp_auth_token']}"

        response = {"Next" => url}
        report = {
          features: [],
          unassigned: [],
          requests: [],
        }

        while(response["Next"])
          parsed_req, response = get_report_payload(response["Next"] + auth_token)

          report[:features].concat parsed_req[:features]
          report[:requests].concat parsed_req[:requests]
          report[:unassigned].concat parsed_req[:unassigned]
        end
          report = clean_report(report)
          report_to_csv(report)
      end

      private

      def clean_report(report)
        projects = report.map { |item| item.second.map { |assignable| assignable.values.first.is_a?(Hash) ? assignable.values.first["project"] : assignable.values.second }.compact }.flatten.uniq
        features = report[:features].map { |feature| feature.keys }.flatten.uniq
        requests = report[:requests].map { |request| request.keys }.flatten.uniq
        feature_user_stories = report[:features].map { |feature| feature.values.map { |user_story| { user_story.keys.first => {feature.keys.first => user_story.values.first, user_story.keys.second => user_story.values.second, user_story.keys.third => user_story.values.third, user_story.keys.fourth => user_story.values.fourth } } } }.flatten.uniq
        request_user_stories = report[:requests].map { |request| request.values.map { |user_story| { user_story.keys.first => {request.keys.first => user_story.values.first, user_story.keys.second => user_story.values.second, user_story.keys.third => user_story.values.third, user_story.keys.fourth => user_story.values.fourth } } } }.flatten.uniq

        clean_features_by_project   = clean_items(projects, features, feature_user_stories)
        clean_requests_by_project   = clean_items(projects, requests, request_user_stories)
        clean_unassinged_by_project = clean_unassinged(projects, report[:unassigned])

        [clean_features_by_project, clean_requests_by_project, clean_unassinged_by_project]
      end

      def clean_items(projects, items, item_user_stories)
        clean_items = projects.map { |project|
          { project =>
            items.map { |item|
              item_user_stories
              .select { |user_story|
                user_story.values.first.keys.first == item && user_story.values.first.values.second == project
              }
            }.keep_if { |user_stories| !user_stories.empty? }
          }
        }.keep_if { |item| !item.values.first.empty? }
      end

      def clean_unassinged(projects, items)
        clean_items = projects.map { |project|
          { project =>
            items.select { |item|
              item.values.second == project
            }
          }
        }.keep_if { |item| !item.values.first.empty? }
      end

      def report_to_csv(report)
        CSV.generate do |csv|

          csv << ["Project", "Engineer Level", "Feature\\Request", "User Story", "Time Spent"]

          csv << ["Features", "", "", "", ""]

          report.first.each do |project|
            project.values.first.each do |project_user_stories|
              project_user_stories.each_with_index do |user_story, index|
                csv << ["#{user_story.values.first["project"]}", "#{user_story.values.first["user_level"].titleize}", "#{user_story.values.first.keys.first}", "#{user_story.keys.first}", "#{user_story.values.first.values.first}"]
              end
            end
          end

          csv << ["Requests", "", "", "", ""]

          report.second.each do |project|
            project.values.first.each do |project_user_stories|
              project_user_stories.each_with_index do |user_story, index|
                csv << ["#{user_story.values.first["project"]}", "#{user_story.values.first["user_level"].titleize}", "#{user_story.values.first.keys.first}", "#{user_story.keys.first}", "#{user_story.values.first.values.first}"]
              end
            end
          end

          csv << ["Orphan UserStories", "", "", "", ""]

          report.third.each do |project|
            project.values.each do |user_stories|
              user_stories.each_with_index do |user_story, index|
              csv << ["#{user_story["project"]}", "#{user_story["user_level"].titleize}", "N/A", "#{user_story.keys.first}", "#{user_story.values.first}"]
              end
            end
          end

        end
      end

      def get_report_payload(url)
        response = request_from_tp(URI(url), "get")
        items = response["Items"]
        [parse_report(items), response]
      end

      def parse_report items
        unassigned = parse_items(items)
        features = parse_items(items, "Feature")
        requests = parse_items(items, "Request")

        format_report(unassigned, requests, features)
      end

      def parse_items(items, item_type=nil)
        condition1 = item_type ? lambda { |item| item["UserStory"] != nil } : lambda { |item| item["UserStory"] == nil || (item["UserStory"]["Feature"] == nil && !is_request?(item)) }
        condition2 = item_type ? item_type == "Feature" ? lambda { |item| item["UserStory"]["Feature"] != nil } : lambda { |item| is_request?(item) } : lambda { |item| item }
        items
          .select(&condition1)
          .select(&condition2)
          .map { |item| transform_item(item, item_type) }
      end

      def is_request?(item)
        item["UserStory"]["InboundAssignables"]["Items"] != [] &&
        item["UserStory"]["InboundAssignables"]["Items"].any? do |relation|
          relation["EntityType"]["Name"] == "Request"
        end
      end

      def transform_item(item, type=nil)
        assignable = item["Assignable"]
          assignable_key = "#{assignable["ResourceType"]} #{assignable["Id"]} #{assignable["Name"]}"
          user = User.find_by(tp_user_id: item["User"]["Id"])
          if (type == "Feature")
            {"Feature #{item["UserStory"]["Feature"]["Id"]} #{item["UserStory"]["Feature"]["Name"]}" => {"#{assignable_key}" => item["Spent"], "project" => item["Project"]["Name"], "user_level" => user.level, "Time Stamp" => item["CreateDate"]}}
          elsif (type == "Request")
            request = item["UserStory"]["InboundAssignables"]["Items"].select { |relation| relation["EntityType"]["Name"] == "Request" }
            { "Request #{request[0]["Id"]} #{request[0]["Name"]}" => {"#{assignable_key}" => item["Spent"], "project" => item["Project"]["Name"], "user_level" => user.level}}
          else
            {"#{assignable_key}" => item["Spent"], "project" => item["Project"]["Name"], "user_level" => user.level}
          end
      end

      def format_report(unassigned, requests, features)
        {
          features: features,
          requests: requests,
          unassigned: unassigned,
        }
      end

      def request_from_tp url, type, payload = {}
        if type == "get"
          req = Net::HTTP::Get.new url
        elsif type == "post"
          req = Net::HTTP::Post.new url
          req.body = payload.to_json
        else
          p "You didn't specify a request type"
        end
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
