require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Trinidad lifecycle extension' do
  before(:all) do
    @options = { :path => File.expand_path('../fixtures', __FILE__) }
  end

  before(:each) do
    @context = Trinidad::Tomcat::StandardContext.new
    @tomcat = mock
    @tomcat.stubs(:server).returns(@context)
  end

  context "when it's a server extension" do
    subject { Trinidad::Extensions::LifecycleServerExtension.new(@options) }

    it "adds the listener to the tomcat's server context" do
      subject.configure(@tomcat)
      @tomcat.server.findLifecycleListeners().should have(1).listener
    end
  end

  context "when it's a webapp extension" do
    subject { Trinidad::Extensions::LifecycleWebAppExtension.new(@options) }

    it "adds the listener to the application context" do
      app_context = Trinidad::Tomcat::StandardContext.new
      subject.configure(@tomcat, app_context)
      app_context.findLifecycleListeners().should have(1).listener
    end
  end
end
