require 'singleton'

module Wikipedia
  class Configuration
    include Singleton

    def self.directives(*directives)
      directives.each do |directive|
        define_method directive do |*args|
          return instance_variable_get("@#{directive}") if args.empty?

          instance_variable_set("@#{directive}", args.first)
        end
      end
    end

    def self.[](directive)
      instance.send(directive)
    end

    directives :protocol, :domain, :path, :user_agent
  end
end
