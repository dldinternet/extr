module Extr
 module DirectController

  DEFAULT_METHODS = {}

  def self.included(base)
   base.extend ClassMethods
  end

  module ClassMethods

   def extdirect(*methods)
=begin
    options = methods.extract_options!
    action = options.delete(:name) || self.to_s.gsub(":","")
    Config.controller_path[action]=self.to_s
    Config.controller_config[action].clear

    options.delete(:methods).stringify_keys!.merge!(DEFAULT_METHODS).each do |mtd, mcfg|
     if mcfg.is_a?(Hash)
      Config.controller_config[action] << {'name' => mtd, 'formHandler' => true}.merge!(mcfg)
     else
      Config.controller_config[action] << { 'name' => mtd, 'len' => mcfg || 1, 'formHandler' => true }
     end
    end
   rescue => ex
    Rails.logger.error ex.message
    Rails.logger.error ex.backtrace
=end
   end

  end

 end
end

