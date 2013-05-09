require "test_helper"

class ScoresControllerTest < ActionController::TestCase

  before do
    @score = scores(:one)
  end

  def test_index
    get :index
    assert_response :success
    assert_not_nil assigns(:scores)
  end

  def test_new
    get :new
    assert_response :success
  end

  def test_create
    assert_difference('Score.count') do
      post :create, score: {  }
    end

    assert_redirected_to score_path(assigns(:score))
  end

  def test_show
    get :show, id: @score
    assert_response :success
  end

  def test_edit
    get :edit, id: @score
    assert_response :success
  end

  def test_update
    put :update, id: @score, score: {  }
    assert_redirected_to score_path(assigns(:score))
  end

  def test_destroy
    assert_difference('Score.count', -1) do
      delete :destroy, id: @score
    end

    assert_redirected_to scores_path
  end
end
