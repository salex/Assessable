require "test_helper"

class SurveyorsControllerTest < ActionController::TestCase

  before do
    @surveyor = surveyors(:one)
  end

  def test_index
    get :index
    assert_response :success
    assert_not_nil assigns(:surveyors)
  end

  def test_new
    get :new
    assert_response :success
  end

  def test_create
    assert_difference('Surveyor.count') do
      post :create, surveyor: {  }
    end

    assert_redirected_to surveyor_path(assigns(:surveyor))
  end

  def test_show
    get :show, id: @surveyor
    assert_response :success
  end

  def test_edit
    get :edit, id: @surveyor
    assert_response :success
  end

  def test_update
    put :update, id: @surveyor, surveyor: {  }
    assert_redirected_to surveyor_path(assigns(:surveyor))
  end

  def test_destroy
    assert_difference('Surveyor.count', -1) do
      delete :destroy, id: @surveyor
    end

    assert_redirected_to surveyors_path
  end
end
