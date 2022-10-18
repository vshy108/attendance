require 'test_helper'

class Api::V1::PunchTimesControllerTest < ActionDispatch::IntegrationTest
  include Qrcode

  setup do
    @user_0 = users(:user_0)
    @worker_0 = workers(:worker_0)
    post '/api/v1/auth/sign_in.json', params: { username: @user_0.username, password: 'password0' }
    @access_token = response.header['Access-Token']
    @client = response.header['Client']
    @uid = response.header['Uid']
  end

  test "should create punch time with only qr code" do
    assert_difference 'PunchTime.count' do
      post '/api/v1/punch_times', headers: { 'access-token' => @access_token, 'client' => @client, 'uid' => @uid }, params: {
        punch_time: { qr_code: encode(@worker_0.id) }
      }
    end
    assert_response :ok
    punch_time = JSON.parse response.body
    assert_equal @worker_0.name, punch_time.dig("included").dig(0).dig("attributes").dig("name")
    assert_equal @worker_0.qr_code, punch_time.dig("included").dig(0).dig("attributes").dig("qr_code")
  end

  test "should not create punch time if qr code is not found" do
    not_exist_id = ((1..(Worker.count + 1)).to_a - Worker.pluck(:id)).first
    assert_no_difference 'PunchTime.count' do
      post '/api/v1/punch_times', headers: { 'access-token' => @access_token, 'client' => @client, 'uid' => @uid }, params: {
        punch_time: { qr_code: encode(not_exist_id) }
      }
    end
    assert_response :unprocessable_entity
    error_body = JSON.parse response.body
    assert error_body.key?('errors')
  end

  test "should get punch time history according to page limit" do
    limit = 30
    punch_time_size = PunchTime.count
    page = punch_time_size / limit + 1
    get "/api/v1/punch_time_history?limit=#{limit}&page=#{page}", headers: { 'access-token' => @access_token, 'client' => @client, 'uid' => @uid }
    assert_response :ok
    punch_time_history = JSON.parse response.body
    assert_equal punch_time_size - (limit * (page - 1)), punch_time_history.dig('data').count
    uri = Addressable::URI.parse(punch_time_history.dig('links').dig('last'))
    assert_equal limit, uri&.query_values&.dig('limit')&.to_i
    assert_equal page, uri&.query_values&.dig('page')&.to_i
    assert punch_time_history.dig('included').count.positive?
  end

  test "should get empty punch time history if exceeding page limit" do
    limit = 40
    punch_time_size = PunchTime.count
    page = punch_time_size / limit + 2
    get "/api/v1/punch_time_history?limit=#{limit}&page=#{page}", headers: { 'access-token' => @access_token, 'client' => @client, 'uid' => @uid }
    assert_response :ok
    punch_time_history = JSON.parse response.body
    assert_equal 0, punch_time_history.dig('data').count
  end

  # test "should not create punch time if database has punch time within min_punch_diff_minutes before" do
  test "should not create punch time continuously" do
    assert_difference 'PunchTime.count' do
      post '/api/v1/punch_times', headers: { 'access-token' => @access_token, 'client' => @client, 'uid' => @uid }, params: {
        punch_time: { qr_code: encode(@worker_0.id) }
      }
    end
    assert_response :ok
    assert_no_difference 'PunchTime.count' do
      post '/api/v1/punch_times', headers: { 'access-token' => @access_token, 'client' => @client, 'uid' => @uid }, params: {
        punch_time: { qr_code: encode(@worker_0.id) }
      }
    end
    assert_response :unprocessable_entity
    error_body = JSON.parse response.body
    assert error_body["errors"].present?
  end
end
