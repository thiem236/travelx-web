require 'test_helper'

class Api::V1::TripsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_v1_trip = api_v1_trips(:one)
  end

  test "should get index" do
    get api_v1_trips_url
    assert_response :success
  end

  test "should get new" do
    get new_api_v1_trip_url
    assert_response :success
  end

  test "should create api_v1_trip" do
    assert_difference('Api::V1::Trip.count') do
      post api_v1_trips_url, params: { api_v1_trip: { cover_picture: @api_v1_trip.cover_picture, description: @api_v1_trip.description, lat: @api_v1_trip.lat, name: @api_v1_trip.name } }
    end

    assert_redirected_to api_v1_trip_url(Api::V1::Trip.last)
  end

  test "should show api_v1_trip" do
    get api_v1_trip_url(@api_v1_trip)
    assert_response :success
  end

  test "should get edit" do
    get edit_api_v1_trip_url(@api_v1_trip)
    assert_response :success
  end

  test "should update api_v1_trip" do
    patch api_v1_trip_url(@api_v1_trip), params: { api_v1_trip: { cover_picture: @api_v1_trip.cover_picture, description: @api_v1_trip.description, lat: @api_v1_trip.lat, name: @api_v1_trip.name } }
    assert_redirected_to api_v1_trip_url(@api_v1_trip)
  end

  test "should destroy api_v1_trip" do
    assert_difference('Api::V1::Trip.count', -1) do
      delete api_v1_trip_url(@api_v1_trip)
    end

    assert_redirected_to api_v1_trips_url
  end
end
