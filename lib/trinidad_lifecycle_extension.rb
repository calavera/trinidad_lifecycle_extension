module Trinidad
  module Extensions
    module Lifecycle
      VERSION = '0.1.0'

      def init_listeners(context, path, mod_name)
        Dir.glob("#{path}/*.rb").each do |listener|
          load listener
        end

        if Object.const_defined? mod_name
          mod = Object.const_get(mod_name)
          mod.constants.each do |listener|
            context.add_lifecycle_listener(mod.const_get(listener).new)
          end
        end
      end
    end


    class LifecycleServerExtension < ServerExtension
      include Lifecycle

      def configure(tomcat)
        init_listeners(tomcat.server, @options[:path], 'Trinidad::Lifecycle::Server')
      end
    end

    class LifecycleWebAppExtension < WebAppExtension
      include Lifecycle

      def configure(tomcat, app_context)
        init_listeners(app_context, @options[:path], 'Trinidad::Lifecycle::WebApp')
      end
    end
  end
end
