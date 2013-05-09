require "test_helper"

class AssessorSectionsControllerTest < ActionController::TestCase

  before do
    @assessor_section = assessor_sections(:one)
  end

  def test_index
    get :index
    assert_response :success
    assert_not_nil assigns(:assessor_sections)
  end

  def test_new
    get :new
    assert_response :success
  end

  def test_create
    assert_difference('AssessorSection.count') do
      post :create, assessor_section: {  }
    end

    assert_redirected_to assessor_section_path(assigns(:assessor_section))
  end

  def test_show
    get :show, id: @assessor_section
    assert_response :success
  end

  def test_edit
    get :edit, id: @assessor_section
    assert_response :success
  end

  def test_update
    put :update, id: @assessor_section, assessor_section: {  }
    assert_redirected_to assessor_section_path(assigns(:assessor_section))
  end

  def test_destroy
    assert_difference('AssessorSection.count', -1) do
      delete :destroy, id: @assessor_section
    end

    assert_redirected_to assessor_sections_path
  end
end
