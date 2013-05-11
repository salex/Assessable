# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130511105529) do

  create_table "assessable_answers", :force => true do |t|
    t.integer  "question_id"
    t.integer  "sequence"
    t.string   "answer_text"
    t.string   "short_name"
    t.float    "value"
    t.boolean  "requires_other", :default => false
    t.string   "other_question"
    t.string   "text_eval"
    t.string   "key"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "assessable_answers", ["question_id"], :name => "index_assessable_answers_on_question_id"

  create_table "assessable_assessments", :force => true do |t|
    t.string   "name"
    t.string   "category"
    t.string   "description"
    t.string   "instructions"
    t.string   "key"
    t.string   "default_tag"
    t.string   "default_layout"
    t.float    "max_raw"
    t.float    "max_weighted"
    t.string   "status"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "assessing_key"
  end

  add_index "assessable_assessments", ["assessing_key"], :name => "index_assessable_assessments_on_assessing_key"

  create_table "assessable_questions", :force => true do |t|
    t.integer  "assessment_id"
    t.integer  "sequence"
    t.string   "question_text"
    t.string   "short_name"
    t.string   "instructions"
    t.string   "group_header"
    t.string   "answer_tag"
    t.string   "answer_layout"
    t.float    "weight",        :default => 1.0
    t.boolean  "critical"
    t.float    "min_critical"
    t.string   "score_method"
    t.string   "key"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "assessable_questions", ["assessment_id"], :name => "index_assessable_questions_on_assessment_id"

  create_table "assessable_stashes", :force => true do |t|
    t.string   "session_id"
    t.text     "session"
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "assessable_stashes", ["session_id"], :name => "index_assessable_stashes_on_session_id"

  create_table "assessor_sections", :force => true do |t|
    t.integer  "assessor_id"
    t.integer  "assessment_id"
    t.integer  "sequence"
    t.string   "name"
    t.string   "status"
    t.string   "instructions"
    t.string   "category"
    t.float    "max"
    t.float    "weighted"
    t.text     "published"
    t.datetime "published_at"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "assessors", :force => true do |t|
    t.string   "assessoring_type"
    t.integer  "assessoring_id"
    t.string   "assessed_model"
    t.string   "name"
    t.string   "status"
    t.string   "instructions"
    t.string   "method"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "scores", :force => true do |t|
    t.integer  "assessor_section_id"
    t.string   "assessed_type"
    t.integer  "assessed_id"
    t.string   "status"
    t.float    "raw"
    t.float    "weighted"
    t.text     "scoring"
    t.string   "answers"
    t.string   "category"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "stages", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "surveyors", :force => true do |t|
    t.integer  "assessment_id"
    t.integer  "sequence"
    t.string   "assessable_type"
    t.integer  "assessable_id"
    t.text     "published_assessment"
    t.datetime "version_at"
    t.string   "name"
    t.string   "category"
    t.text     "instructions"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "role"
  end

end
