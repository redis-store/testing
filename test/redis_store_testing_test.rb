require 'test_helper'
require_relative '../lib/redis-store/testing/tasks'

class RedisStoreTestingTest < Minitest::Test
  def test_install
    assert RedisStoreTesting.install_tasks
  end
end
