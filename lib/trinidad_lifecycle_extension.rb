require 'rubygems'
gem 'trinidad_jars'
require 'trinidad/extensions'
require 'java'

module Trinidad
  module Extensions
    module Lifecycle
      VERSION = '0.2.1'

      def init_listeners(context, path, mod_name)
        path ||= File.join('lib', 'lifecycle')

        Dir.glob("#{path}/*.rb").each do |listener|
          load listener
        end

        mod = constantize(mod_name)
        return unless mod

        mod.constants.each do |listener|
          const_listener = mod.const_get(listener)
          context.add_lifecycle_listener(const_listener.new)
        end
      end

      def constantize(mod)
        names = mod.split('::')
        names.inject(Object) {|constant, obj| constant.const_get(obj) } rescue nil
      end

      def trap_signals(tomcat)
        trap('INT') { tomcat.stop }
        trap('TERM') { tomcat.stop }
      end
    end


    class LifecycleServerExtension < ServerExtension
      include Lifecycle

      def configure(tomcat)
        trap_signals(tomcat)
        init_listeners(tomcat.server, @options[:path], 'Trinidad::Lifecycle::Server')
      end
    end

    class LifecycleWebAppExtension < WebAppExtension
      include Lifecycle

      def configure(tomcat, app_context)
        trap_signals(tomcat)
        init_listeners(app_context, @options[:path], 'Trinidad::Lifecycle::WebApp')
      end
    end

    class LifecycleOptionsExtension < OptionsExtension
      def configure(parser, default_options)
        default_options[:extensions] ||= {}
        default_options[:extensions][:lifecycle] = {}
      end
    end
  end
end
