require 'rubygems'
gem 'trinidad_jars'
require 'trinidad/extensions'

module Trinidad
  module Extensions
    module Lifecycle
      VERSION = '0.1.0'

      DEFAULT_JMX_OPTIONS = {
        :port => '8181',
        :authenticate => false
      }

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
        if @options.has_key?(:path)
          init_listeners(tomcat.server, @options[:path], 'Trinidad::Lifecycle::Server')
        end
        if @options.has_key?(:jmx)
          export_jmx_settings

          require File.expand_path('../../trinidad-libs/tomcat-catalina-jmx-remote', __FILE__)
          tomcat.server.add_lifecycle_listener(org.apache.catalina.mbeans.JmxRemoteLifecycleListener.new)
        end
      end

      def export_jmx_settings
        options = DEFAULT_JMX_OPTIONS.merge(@options[:jmx] || {})

        set_property("com.sun.management.jmxremote", "true")
        set_property("com.sun.management.jmxremote.port", options[:port])

        set_property("com.sun.management.jmxremote.ssl", options[:ssl_enabled])
        set_property("com.sun.management.jmxremote.ssl.enabled.protocols", options[:ssl_protocols])
        set_property("com.sun.management.jmxremote.ssl.enabled.cipher.suites", options[:ssl_cypher_suites])
        set_property("com.sun.management.jmxremote.ssl.need.client.auth", options[:ssl_auth])
        set_property("com.sun.management.jmxremote.authenticate", options[:authenticate])
        set_property("com.sun.management.jmxremote.password.file", options[:password_file])
        set_property("com.sun.management.jmxremote.access.file", options[:access_file])
      end

      private
      def set_property(name, option)
        java.lang.System.set_property(name, option) if option
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
