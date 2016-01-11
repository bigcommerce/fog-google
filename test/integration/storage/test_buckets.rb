require "helpers/integration_test_helper"

class TestBuckets < FogIntegrationTest
  begin
    client_email = Fog.credentials[:google_client_email]
    @@connection = Fog::Storage::Google.new
    @@connection.delete_bucket("fog-smoke-test")
  rescue Exception => e
    # puts e
  end

  def setup
    # Uncomment this if you want to make real requests to GCE (you _will_ be billed!)
    # WebMock.disable!

    @connection = @@connection
  end

  def teardown
    begin
      @connection.delete_bucket("fog-smoke-test")
    rescue
    end
  end

  def test_put_bucket
    response = @connection.put_bucket("fog-smoke-test")
    assert_equal response.status, 200
  end

  def test_put_bucket_acl
    response = @connection.put_bucket("fog-smoke-test", options={ 'x-goog-acl' => 'publicReadWrite' })
    assert_equal response.status, 200
    acl = { entity: 'domain-google.com',
            role: 'READER' }
    response = @connection.put_bucket_acl("fog-smoke-test", acl)
    assert_equal response.status, 200
  end

  def test_delete_bucket
    response = @connection.put_bucket("fog-smoke-test")
    assert_equal response.status, 200
    response = @connection.delete_bucket("fog-smoke-test")
    assert_equal response.status, 204
  end

  def test_get_bucket
    response = @connection.put_bucket("fog-smoke-test")
    assert_equal response.status, 200
    response = @connection.get_bucket("fog-smoke-test")
    assert_equal response.status, 200
  end

  def test_get_bucket_acl
    response = @connection.put_bucket("fog-smoke-test", 
      options={ 'acl' => [{ entity: 'user-fake@developer.gserviceaccount.com', role: 'OWNER' }] })
    assert_equal response.status, 200
    response = @connection.get_bucket_acl("fog-smoke-test")
    assert_equal response.status, 200
  end
end