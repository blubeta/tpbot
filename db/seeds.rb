# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Command.create([
  {
  name: "help",
  description: "Provides information about commands.",
  usage: "/tp help command",
  aliases: nil,
  },
  {
  name: "reference",
  description: "Creates a link to a TargetProcess entity and sends it to the channel.",
  usage: "/tp reference entity_id",
  aliases: "/tp ref, /tp card",
  },
  {
  name: "ref",
  description: "Creates a link to a TargetProcess entity and sends it to the channel.",
  usage: "/tp ref entity_id",
  aliases: "/tp reference, /tp card",
  },
  {
  name: "card",
  description: "Creates a link to a TargetProcess entity and sends it to the channel.",
  usage: "/tp card entity_id",
  aliases: "/tp reference, /tp ref",
  },
  name: "showme",
  description: "Displays TargetProcess Card Data",
  usage: "/tp showme entity_id",
  aliases: nil,
  },
  {
  name: "gettime",
  description: "Shows how much time everyone has worked",
  usage: "/tp getTime -user firstName -since yyyy-mm-dd",
  aliases: "/tp gettimes",
  },
  {
  name: "gettimes",
  description: "Shows how much time everyone has worked",
  usage: "/tp getTimes -user firstName -since yyyy-mm-dd",
  aliases: "/tp gettime",
  },
  {
  name: "timer",
  description: "Controlls Harvest and TargetProcess timers simultaneously",
  usage: "/tp timer start/stop/list/switch card_id",
  aliases: nil,
  },
  {
  name: "tasks",
  description: "Shows you your TargetProcess tasks",
  usage: "/tp tasks",
  aliases: nil,
  },
  {
  name: "ping",
  description: "Pong!",
  usage: "/tp ping",
  aliases: nil,
  }
])

User.create([
  {
    first_name: "bryan",
    last_name: "padron",
    tp_user_id: 21,
    harvest_user_id: 1769063,
  },
  {
    first_name: "ivanmartinez",
    last_name: nil,
    tp_user_id: 23,
    harvest_user_id: 1769063,
  },
  {
    first_name: "antonio",
    last_name: "manueco",
    tp_user_id: 1,
    harvest_user_id: 413235,
  },
  {
    first_name: "jerry",
    last_name: "bold",
    tp_user_id: 24,
    harvest_user_id: 672190,
  },
  {
    first_name: "alexandra",
    last_name: "alvares",
    tp_user_id: 20,
    harvest_user_id: 1763903,
  },
  {
    first_name: "jenge",
    last_name: "engelmajer",
    tp_user_id: 31,
    harvest_user_id: 1825614,
  },
  {
    first_name: "isaac",
    last_name: "weinbach",
    tp_user_id: 18,
    harvest_user_id: 1330457,
  },
  {
    first_name: "maddie",
    last_name: "campos",
    tp_user_id: 29,
    harvest_user_id: 1330456,
  }
])
