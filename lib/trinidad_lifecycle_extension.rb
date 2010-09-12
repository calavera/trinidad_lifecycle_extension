require 'rubygems'
gem 'trinidad_jars'
require 'trinidad/extensions'

module Trinidad
  module Extensions
    module Lifecycle
      VERSION = '0.1.0'

      def init_listeners(context, path, mod_name)
        Dir.glob("#{path}/*.rb").each do |listener|
          load listener
        end

        mod = constantize(mod_name)

        mod.constants.each do |listener|
          const_listener = mod.const_get(listener)
          context.add_lifecycle_listener(const_listener.new)
        end
      end

      def constantize(mod)
        names = mod.split('::')
        names.inject(Object) {|constant, obj| constant.const_get(obj) }
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
