module Trinidad
  module Lifecycle
    import org.apache.catalina.LifecycleListener
    import org.apache.catalina.Lifecycle

    module Server
      class FakeServerListener
        include LifecycleListener

        def lifecycleEvent(event)
        end
      end
    end

    module WebApp
      class FakeWebAppListener
        include LifecycleListener

        def lifecycleEvent(event)
        end
      end
    end
  end
end
