require 'test_helper'

class SearchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @search = searches(:one)
  end

  test "should show search" do
    get search_url(@search), as: :json
    assert_response :success
  end
end
