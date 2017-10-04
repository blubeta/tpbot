class Command < ApplicationRecord

  def add_alias(alias_name)
    command_aliases = strip_aliases
    return false if all_aliases.include? alias_name
    self.aliases += " /tp #{alias_name}"
    self.save
  end

  def remove_alias(alias_name)
    command_aliases = strip_aliases
    return false if !command_aliases.include? alias_name
    command_aliases.delete(alias_name)
    command_aliases = command_aliases.join(", /tp ")
    self.aliases = "/tp " + command_aliases
    self.save
  end

  private

  def strip_aliases
    command_aliases = self.aliases.gsub(" ", "").gsub(",","").split("/tp")
    command_aliases.shift
    command_aliases
  end

  def all_aliases
    all_aliases = Command.pluck(:aliases)
    all_aliases.delete(nil)
    all_aliases = all_aliases.join
    all_aliases = all_aliases.gsub(" ", "").gsub(",","").split("/tp")
    all_aliases.shift
    all_aliases.uniq
  end

end
