module Trinidad
  module Lifecycle

    module Server
      class FakeServerListener
        include Trinidad::Tomcat::LifecycleListener

        def lifecycleEvent(event)
        end
      end
    end

    module WebApp
      class FakeWebAppListener
        include Trinidad::Tomcat::LifecycleListener

        def lifecycleEvent(event)
        end
      end
    end
  end
end
