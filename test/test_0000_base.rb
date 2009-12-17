require 'rubygems'
require 'stomp'
require 'test/unit'
require 'yaml'
#
# $:.unshift File.dirname(__FILE__)
#
class Test_0000_Base < Test::Unit::TestCase

  def setup
    @runparms = load_config()
    @conn = nil
  end # of setup

  private
  #
  def load_config()
    yfname = File.join(File.dirname(__FILE__), "props.yaml")
    parms = YAML.load(File.open(yfname))
    parms
  end

  protected
  #
  def check_parms()
    assert_not_nil(@runparms[:userid],"userid should not be nil")
    assert_not_nil(@runparms[:password],"userid should not be nil")
    assert_not_nil(@runparms[:host],"userid should not be nil")
    assert_not_nil(@runparms[:port],"userid should not be nil")
  end
  #
  def open_conn()
    assert_nothing_raised() {
      @conn = Stomp::Connection.open(@runparms[:userid],
        @runparms[:password], 
        @runparms[:host], 
        @runparms[:port])
    }
  end
  #
  def disconnect_conn()
    if @conn
      assert_nothing_raised() {
        @conn.disconnect
      }
    end
    @conn = nil
  end

end # of class

