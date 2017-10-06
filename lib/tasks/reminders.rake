task :remind_users => :environment do
  running_timers = Timer.where(running: true, paused: false)
  messages = [
    "Don't forget to turn off your timer :pepe:",
    "Timers dont stop themselves :pepe:",
    "A timer is still running, just letting you know :pepe:"
  ]
  running_timers.each do |timer|
    # Slack::Messenger.send_message(messages[rand(3)])
  end
end
