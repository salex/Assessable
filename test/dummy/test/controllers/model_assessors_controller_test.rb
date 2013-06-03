require "test_helper"

describe ModelAssessorsController do

  before do
    @model_assessor = model_assessors(:one)
    user = User.create(:username => 'test', :role => 'test')
    session[:user_id] = user.id
  end

  it "must get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:model_assessors)
  end

  it "must get new" do
    get :new
    assert_response :success
  end

  it "must create model_assessor" do
    assert_difference('ModelAssessor.count') do
      post :create, model_assessor: {  }
    end

    assert_redirected_to model_assessor_path(assigns(:model_assessor))
  end

  it "must show model_assessor" do
    get :show, id: @model_assessor
    assert_response :success
  end

  it "must get edit" do
    get :edit, id: @model_assessor
    assert_response :success
  end

  it "must update model_assessor" do
    put :update, id: @model_assessor, model_assessor: {  }
    assert_redirected_to model_assessor_path(assigns(:model_assessor))
  end

  it "must destroy model_assessor" do
    assert_difference('ModelAssessor.count', -1) do
      delete :destroy, id: @model_assessor
    end

    assert_redirected_to model_assessors_path
  end

end
