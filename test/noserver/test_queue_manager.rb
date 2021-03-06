require 'logger'
$:.unshift File.dirname(__FILE__)
require 'mocklogger'
#
require 'stomp_server/stomp_id'
require 'stomp_server/stomp_frame'
require 'stomp_server/queue_manager'
require 'stomp_server/queue'
require 'stomp_server/queue/file_queue'
require 'stomp_server/queue/memory_queue'
require 'stomp_server/queue/dbm_queue'
require 'test/unit'
require 'fileutils'

class TestQueues < Test::Unit::TestCase

  class MockQueueManager < StompServer::QueueManager
    def initialize(qstore)
      super(qstore)
      @qstore = qstore
      @queue_stats = Hash.new
      @queues = Hash.new { Array.new }
      @pending = Hash.new { Array.new }
    end
  end
  
  class UserMock
    attr_accessor :data
    def initialize ; @data = '' ; end
    def stomp_send_data(data); @data += data.to_s ; end
    def connected?;true;end
  end
  
  class MessageMock
    attr_accessor :headers, :data, :command, :body
    def initialize(dest, msg, id=1)
      @body = msg
      @headers = {
        'message-id' => id,
        'destination' => dest,
        'content-length' => msg.size.to_s
      }

      @frame = StompServer::StompFrame.new('MESSAGE', headers, body)
      @data = @frame.to_s
    end
    def to_s ; @data.to_s ; end
  end

  def teardown
    FileUtils.rm_rf(".queue_test")
  end

  def setup
    FileUtils.rm_rf(".queue_test") if File.directory?('.queue_test')
    @@qstore = StompServer::FileQueue.new(".queue_test")
    @@qstore.checkpoint_interval=0
    @t = MockQueueManager.new(@@qstore)
    @log = Logger.new(STDOUT)
    @log.level = Logger::DEBUG
  end

  # def test_subscribe
  #   u = UserMock.new
  #   t = 'foo'
  #   @t.subscribe(t, u)
  #   
  #   m1 = MessageMock.new('foo', 'foomsg')
  #   m2 = MessageMock.new('bar', 'barmsg')
  #   @t.sendmsg(m1)
  #   assert_equal(m1.data, u.data)
  #   
  #   u.data = ''
  #   @t.sendmsg(m2)
  #   assert_equal('', u.data)
  # end

  def test_subscribe2
    @log.debug("test_subscribe2 starts")
    t = 'sub2'
    m1 = MessageMock.new(t, 'sub2msg')
    @t.sendmsg(m1)
    
    u = UserMock.new
    @t.subscribe(t, u)
    
    assert_equal(m1.data, u.data)
    @log.debug("test_subscribe2 ends")
  end

  # def test_unsubscribe
  #   u = UserMock.new
  #   t = 'foo'
  #   @t.subscribe(t, u)
  #   
  #   m1 = MessageMock.new('foo', 'foomsg')
  #   @t.sendmsg(m1)
  #   assert_equal(m1.data, u.data)
  # 
  #   @t.unsubscribe(t,u)
  #   u.data = ''
  #   @t.sendmsg(m1)
  #   assert_equal('', u.data)        
  # end

  # def test_sendmsg
  #   u = UserMock.new
  #   t = 'foo'
  #   @t.subscribe(t, u)
  #   
  #   m1 = MessageMock.new('foo', 'foomsg')
  #   @t.sendmsg(m1)
  #   assert_equal(m1.data, u.data)
  #   assert_equal('MESSAGE', m1.command)
  # end

  def test_queued_sendmsg
    @log.debug("test_queued_sendmsg starts")
    t = 'foo'
    m1 = MessageMock.new('foo', 'foomsg')
    @t.sendmsg(m1)
    
    u = UserMock.new
    @t.subscribe(t, u)
    
    assert_equal(m1.data, u.data)
    assert_equal('MESSAGE', m1.command)
    
    u2 = UserMock.new
    @t.subscribe(t, u2) 
    assert_equal('', u2.data)
    @log.debug("test_queued_sendmsg ends")
  end
end
