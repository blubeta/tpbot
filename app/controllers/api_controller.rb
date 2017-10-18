class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token

  def tp
    text = params[:text]
    user_name = params[:user_name]
    command = text.split(' ')
    init
    delegate_commands command, user_name
    if @private_message
      render json: Slack::Messenger.send_private_message(@response_text, @attachments), status: 200
    else
      render json: "", status: 200
      Slack::Messenger.send_message(@response_text, params[:channel_id], @attachments)
    end
  end

  def interactions
    event = JSON.parse(params[:payload])
    command = event["callback_id"].split("_")
    event["actions"][0]["selected_options"] ? command << event["actions"][0]["selected_options"][0]["value"].split("_") : command << event["actions"][0]["name"]
    command.flatten!
    user_name = event["user"]["name"]
    if command[-1] != "dismiss"
      init
      delegate_commands command, user_name
    else
      @response_text = "Aight, I see how it is :sad_meme:"
      @attachments = []
    end
    render json: {text: @response_text, attachments: @attachments, replace_original: true}, status: 200
  end

  def meme_machine
    event = params[:event]
    if event[:text] && event[:text].downcase.include?("meme machine")
      @response_text = "https://www.youtube.com/watch?v=wl-LeTFM8zo"
      @attachments = [
        {
          "service_name": "YouTube",
          "service_url": "https://www.youtube.com/",
          "title": "PINK GUY - MEME MACHINE",
          "title_link": "https://www.youtube.com/watch?v=wl-LeTFM8zo",
          "author_name": "TooDamnFilthy",
          "author_link": "https://www.youtube.com/user/TooDamnFilthy",
          "thumb_url": "https://i.ytimg.com/vi/wl-LeTFM8zo/hqdefault.jpg",
          "thumb_width": 480,
          "thumb_height": 360,
          "fallback": "YouTube Video: PINK GUY - MEME MACHINE",
          "video_html": "<iframe width=\"400\" height=\"225\" src=\"https://www.youtube.com/embed/wl-LeTFM8zo?feature=oembed&autoplay=1&iv_load_policy=3\" frameborder=\"0\" allowfullscreen></iframe>",
          "video_html_width": 400,
          "video_html_height": 225,
          "from_url": "https://www.youtube.com/watch?v=wl-LeTFM8zo",
          "service_icon": "https://a.slack-edge.com/2089/img/unfurl_icons/youtube.png",
          "id": 2
        }
      ]
      p Slack::Messenger.send_message(@response_text, event[:channel], @attachments)
      return
    end
    # render json: params[:challenge], status: 200
  end

  private

  def init
    @commands = Command.pluck(:name)
    @aliases, @description, @usage = {}, {}, {}
    @tp_user_ids, @harvest_user_ids = {}, {}

    Command.all.each do |command|
      @usage[command.name] = command.usage
      @description[command.name] = command.description
      @aliases[command.name] = command.aliases if command.aliases
    end

    User.all.each do |user|
      @tp_user_ids[user.first_name] = user.tp_user_id.to_s
      @harvest_user_ids[user.first_name] = user.harvest_user_id.to_s
    end

    @harvest_project_ids = {
      "TIKD Admin Support"      => "13402393",
      "TIKD Development"        => "13402393",
      "TIKD Admin Development"  => "13402393",
      "Guzman"                  => "13966660",
      "Kazu Dashboard"          => "11896705",
      "letsRUMBL"               => "11204341",
      "Sneak Feed"              => "11204327",
      "Watsco"                  => "13301999",
      "Deep Blocks - v1"        => "14502229",
      "blubeta"                 => "4963015",
      "TIKD.com"                => "13402393",
    }

    @harvest_task_id = "1697965"

    @response_text = ""
    @attachments = []
    @private_message = false
  end

  def delegate_commands command, user_name = ""
    user_specific_commands = ["timer", "tasks"]
    params = command.length > 1 ? command.drop(1) : []
    if user_specific_commands.include? command[0].downcase
      params << user_name
    end
    if !command[0]
      method("help").call()
      return
    end
    if @commands.include? command[0].downcase
      begin
        method(command[0].downcase).call(*params)
      rescue => e
        p e
        @response_text = "Command '#{command.join("_")}' broke :sad_meme:"
      end
    else
      @response_text = "Command '#{command[0]}' is invalid :sad_meme:"
    end
  end

  def reference(entity_id=false, *extra_args)
    res = TargetProcess::Handler.get_card("generals", entity_id)
    if res["Status"] != "NotFound"
      if entity_id
        if entity_id.to_i.to_s == entity_id
          @response_text = "https://blubeta.tpondemand.com/entity/#{entity_id}"
        else
          @response_text = "Invalid entity id '#{entity_id}' :sad_meme:"
        end
      else
        @response_text = "Please provide an entity_id :pepe:"
      end
    else
        @response_text = "Id: #{entity_id} is not a card on TargetProcess"
    end
  end
  alias_method :ref, :reference
  alias_method :card, :reference

  def help(command="", *extra_args)
    if @description[(command + " " + extra_args.find_all{ |arg| arg[0] == "-" }.join(" ")).downcase]
      @response_text = "#{@description[(command + " " + extra_args.find_all{ |arg| arg[0] == "-" }.join(" ")).downcase]}"
      @attachments << {title: "Usage:", text: "#{@usage[(command + " " + extra_args.find_all{ |arg| arg[0] == "-" }.join(" ")).downcase]}"}
      @aliases[command.downcase] ? @attachments << {title: "Aliases:", text: @aliases[command.downcase]} : nil
    elsif @description[command.downcase]
      @response_text = "#{@description[command.downcase]}"
      @attachments << {title: "Usage:", text: "#{@usage[command.downcase]}"}
      @aliases[command.downcase] ? @attachments << {title: "Aliases:", text: @aliases[command.downcase]} : nil
    elsif command != "" && extra_args[0]
      @response_text = "Command '#{command}' is not a valid command :sad_meme:"
    else
      @response_text = "Valid commands are: #{@commands.join(", ")}"
      @attachments << {
        title: "Usage:",
        callback_id: "help",
        text: "#{@usage["help"]}",
        actions: [
          {
            name: "help_list",
            text: "Choose a Command...",
            type: "select",
            options: @commands.map { |command_name|
              {
                text: command_name,
                value: command_name
              }
            }
          },
          {
            name: "dismiss",
            text: "Dismiss",
            type: "button",
          }
        ]
      }
      p @commands
    end
  end

  def showme(entity="", entity_id="", *extra_args)
    begin
      type = entity.to_i.to_s != entity ? entity.pluralize : 'generals'
      id = entity_id == '' ? entity : entity_id
      res = TargetProcess::Handler.get_card(type, id)
      name = res["EntityType"]["Name"]
      res = type == "generals" ? TargetProcess::Handler.get_card(name.pluralize, id) : nil
      number = res["Id"].to_s
      response_text = name + " " + number
      colors = {
        "Epic" => "%2300bea0",
        "Feature" => "%231c8300",
        "UserStory" => "%236498d8",
        "Task" => "%231c1c72",
        "Bug" => "%23d86464",
        "Request" => "%23ffc600",
        "TestCase" => "%23cc6600",
        "TestPlan" => "%23c8a606",
        "Release" => "%23999999",
        "Iteration" => "%238ac0f0",
        "TeamIteration" => "%238ac0f0",
        "Build" => "%23449190",
      }
      @attachments << {
        author_name: res["Owner"]["FirstName"] + " " + res["Owner"]["LastName"],
        title: "#{res['Name']} %23#{id}",
        color: "#{colors[name]}",
        title_link: "https://blubeta.tpondemand.com/entity/#{entity}",
        fields: [
          {
            title: "Status",
            value: res["EntityState"]["Name"]
          },
          {
            title: "Time Spent",
            value: res["TimeSpent"].to_s + " Hours"
          }
        ]
      }
    rescue => e
      @response_text = "There was some error getting #{type == "generals" ? "" : "#{type[0...-1]} "}#{id} :sad_meme:"
      @attachments << {
        title: "make sure that you spelled everything correctly :pepe:",
        color: "%23d86464",
      }
    end
  end

  def gettime(*extra_args)
    begin
      dateSpecified = extra_args.index("-since")
      userSpecified = extra_args.index("-user")
      user = userSpecified ? extra_args[userSpecified + 1] : 'no user'
      time = dateSpecified ? extra_args[dateSpecified + 1] : '1970-01-01'
      if (userSpecified && user[/[a-zA-Z]+/] == user && user != "")
        hours = TargetProcess::Handler.get_hours(user, time)
        @response_text = "Time for #{user.humanize} since #{time == '1970-01-01' ? "the beginning of time" : time}:"
        @attachments << {
          title: "#{user.humanize} has worked a total of: #{hours} hours",
          color: "%2300ff00",
        }
      else
        hours = TargetProcess::Handler.get_all_hours(time)
        @response_text = "Times for each user since #{time}"
        hours.each do |user_name, user_hours|
          user_hours = "%.2f".% user_hours
          title = "#{user_name.titleize}: #{user_hours} hours"
          title = title[0..title.index(":")] + (" "*30) + title[title.index(":")+1..-1]
            @attachments << {
              title: title,
              color: "%2300ff00",
            }
        end
      end
    end
  end
  alias_method :gettimes, :gettime

  def timer(*extra_args)
    if extra_args[0]
      message_specified = extra_args.index("-m")
      message = message_specified ? extra_args[(message_specified + 1)..(extra_args.join.rindex('”'))][0..-2].join(" ") : false
      card = extra_args[1] != extra_args[-1] ? extra_args[1] : "no card"
      running_timer = Timer.find_by(tp_user_id: @tp_user_ids[extra_args[-1]], harvest_user_id: @harvest_user_ids[extra_args[-1]], running: true, paused: false)
      if extra_args[0].downcase == "start"
        if card != "no card" && card != ""
          res = TargetProcess::Handler.get_card("generals", card)
          if res["Status"] == "NotFound"
            @response_text = "Id: #{card} is not a card on TargetProcess :sad_meme:"
            return
          elsif res["EntityType"]["Name"] == "Feature"
            @response_text = "Cannot track time on a feature :sad_meme:"
            return
          end
          if running_timer
            running_timer.update(paused: true)
          end
          timer = Timer.find_or_create_by(tp_user_id: @tp_user_ids[extra_args[-1]], harvest_user_id: @harvest_user_ids[extra_args[-1]], tp_card_id: card, running: true)
          @response_text = "Timer Started"
          if timer.paused
            paused_time = timer.paused_time += ((Time.now - timer.updated_at)/3600).round(2)
            timer.update(paused: false, paused_time: paused_time)
            @response_text = "Timer Resumed"
          end
        else
          @response_text = "Please specify a TargetProcess card"
          @attachments << {title: "Usage", text: @usage["timer"]}
        end
      elsif extra_args[0].downcase == "stop"
        if running_timer
          hours = (((Time.now - running_timer.created_at)/3600) - running_timer.paused_time).round(2)
          hours = hours < 0.17 ? 0.17 : hours
          @response_text = "Time tracked: #{hours} hours for <https://blubeta.tpondemand.com/entity/#{running_timer.tp_card_id}|#{running_timer.tp_card_id}>"
          running_timer.update(running: false, hours: hours)
          _export_time(@harvest_user_ids[extra_args[-1]], @tp_user_ids[extra_args[-1]], hours, running_timer.tp_card_id, message)
        else
          @response_text = "You have to star or resume a timer before you can stop one :pepe:"
          @attachments << {title: "/tp timer list", text: "gives you a list of all running timers"}
        end
      elsif extra_args[0].downcase == "list"
        timers = Timer.where(tp_user_id: @tp_user_ids[extra_args[-1]], running: true)
        @response_text = "#{timers.length > 0 ? timers.length : "no"} #{"timer".pluralize(timers.length)} running"
        @attachments = timers.map { |timer|
          hours = (((Time.now - timer.created_at)/3600) - timer.paused_time).round(2)
            {
              title: timer.tp_card_id.to_s + " " + TargetProcess::Handler.get_card("generals", timer.tp_card_id)["Name"],
              title_link: "https://blubeta.tpondemand.com/entity/#{timer.tp_card_id}",
              text: timer.paused ? "Timer Paused" : hours > 0.17 ? hours : hours.to_s + " rounded to 0.17"
            }
          }
      elsif extra_args[0].downcase == "switch"
        timers = Timer.where(tp_user_id: @tp_user_ids[extra_args[-1]], running: true)
        if timers.length > 0
          @response_text = "Which timer would you like to switch to?"
          @attachments << {
            title: "Timers",
            callback_id: "timer_start",
            actions: [
              {
                name: "timer_list",
                text: "Choose a Timer...",
                type: "select",
                options: timers.map { |timer|
                  {
                    text: timer.tp_card_id,
                    value: timer.tp_card_id
                  }
                }
              },
              {
                name: "dismiss",
                text: "Cancel",
                type: "button",
              }
            ]
          }
        else
          @response_text = "No timers to switch to :sad_meme:"
        end
      elsif extra_args[0] != extra_args[-1]
        @response_text = "Expected argument 'start/stop/list/switch' got '#{extra_args[0]}'"
      else
        @response_text = "Expected argument 'start/stop/list/switch' got nothing"
      end
    end
  end

  def tasks(*extra_args)
    if extra_args[0].to_i.to_s == extra_args[0]
    actions = {"Start Timer" => "timer_start_#{extra_args[0]}"}
    card = TargetProcess::Handler.get_card("Generals", extra_args[0])
    @response_text = card["Name"]
    @attachments << {
      title: "Pick an action any action",
      callback_id: "tasks",
      actions: [
        {
          name: "help_list",
          text: "Choose a Action...",
          type: "select",
          options: actions.map { |text, value|
            {
              text: text,
              value: value
            }
          }
        },
        {
          name: "dismiss",
          text: "Dismiss",
          type: "button",
        }
      ]
    }
    elsif extra_args.length > 1
      username = extra_args.pop
      delegate_commands(extra_args, username)
    else
    cards = TargetProcess::Handler.get_user_cards(@tp_user_ids[extra_args[-1]])
      @response_text = "Here's your TargetProcess Cards"
      @attachments << {
        title: "Pick a card any card",
        callback_id: "tasks",
        actions: [
          {
            name: "help_list",
            text: "Choose a Card...",
            type: "select",
            options: cards.map { |card|
              {
                text: "#{card[:id].to_s} #{card[:type]} ",
                value: card[:id]
              }
            }
          },
          {
            name: "dismiss",
            text: "Dismiss",
            type: "button",
          }
        ]
      }
    end
  end

  def ping
    @response_text = "pong! :pepe:"
  end

  def _export_time(harvest_user, tp_user, hours, tp_card_id, description)
    if hours > 0.0
      res = TargetProcess::Handler.get_card("generals", tp_card_id)
      description = description || res["Name"]
      harvest_project = @harvest_project_ids[res["Project"]["Name"]]
      Harvest::Handler.export_time(harvest_user, harvest_project, description, hours, @harvest_task_id)
      TargetProcess::Handler.export_time(tp_user, tp_card_id, hours, description)
    else
      @response_text = "Cannot track time that is less than 0.01 hours :sad_meme:"
      @attachments << {title: "Note:", text: "Regardless the timer that you started was stopped :pepe:"}
    end
  end

end
