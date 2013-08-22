require 'pathname'

class RedisRunner
  attr_reader :dir

  def initialize(dir)
    @dir = dir
  end

  def redisdir
    dir.join 'vendor/redis'
  end

  def start
    system %(redis-server #{configuration})
  end

  def stop
    begin
      Process.kill('SIGTERM', pid)
    rescue
      # Suppress exceptions for Travis CI
    end
  end

  protected
  def configuration
    root.join 'config/redis.conf'
  end

  def pid_file
    dir.join 'tmp/pids/redis.pid'
  end

  def pid
    ::File.open(pid_file).read.to_i
  end

  private
  def root
    @root ||= begin
      root = if Kernel.respond_to?(:__dir__)
        __dir__
      else
        ::File.dirname(__FILE__)
      end

      Pathname.new(root)
    end
  end
end

class NodeOneRedisRunner < RedisRunner
  protected
  def configuration
    root.join 'config/node-one.conf'
  end

  def self.pid_file
    dir.join 'tmp/pids/node-one.pid'
  end
end

class NodeTwoRedisRunner < RedisRunner
  protected
  def configuration
    root.join 'config/node-two.conf'
  end

  def self.pid_file
    dir.join 'tmp/pids/node-two.pid'
  end
end
