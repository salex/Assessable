require "test_helper"

class AssessorsControllerTest < ActionController::TestCase

  before do
    @assessor = assessors(:one)
  end

  def test_index
    get :index
    assert_response :success
    assert_not_nil assigns(:assessors)
  end

  def test_new
    get :new
    assert_response :success
  end

  def test_create
    assert_difference('Assessor.count') do
      post :create, assessor: {  }
    end

    assert_redirected_to assessor_path(assigns(:assessor))
  end

  def test_show
    get :show, id: @assessor
    assert_response :success
  end

  def test_edit
    get :edit, id: @assessor
    assert_response :success
  end

  def test_update
    put :update, id: @assessor, assessor: {  }
    assert_redirected_to assessor_path(assigns(:assessor))
  end

  def test_destroy
    assert_difference('Assessor.count', -1) do
      delete :destroy, id: @assessor
    end

    assert_redirected_to assessors_path
  end
end
