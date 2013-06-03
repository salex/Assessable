require "test_helper"

describe InstructorsController do

  before do
    @instructor = instructors(:one)
    user = User.create(:username => 'test', :role => 'test')
    session[:user_id] = user.id
    
  end

  it "must get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:instructors)
  end

  it "must get new" do
    get :new
    assert_response :success
  end

  it "must create instructor" do
    assert_difference('Instructor.count') do
      post :create, instructor: {  }
    end

    assert_redirected_to instructor_path(assigns(:instructor))
  end

  it "must show instructor" do
    get :show, id: @instructor
    assert_response :success
  end

  it "must get edit" do
    get :edit, id: @instructor
    assert_response :success
  end

  it "must update instructor" do
    put :update, id: @instructor, instructor: {  }
    assert_redirected_to instructor_path(assigns(:instructor))
  end

  it "must destroy instructor" do
    assert_difference('Instructor.count', -1) do
      delete :destroy, id: @instructor
    end

    assert_redirected_to instructors_path
  end

end
