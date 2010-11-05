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

ActiveRecord::Schema.define(:version => 20100919072020) do

  create_table "sprints", :force => true do |t|
    t.string   "scrumworks_id", :null => false
    t.string   "name",          :null => false
    t.date     "starts_on",     :null => false
    t.date     "ends_on",       :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "stories", :force => true do |t|
    t.integer  "sprint_id",     :null => false
    t.string   "scrumworks_id", :null => false
    t.string   "title",         :null => false
    t.integer  "complexity",    :null => false
    t.date     "completed_on"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "task_estimates", :force => true do |t|
    t.integer  "task_id",    :null => false
    t.date     "value_on",   :null => false
    t.integer  "value",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tasks", :force => true do |t|
    t.integer  "story_id",      :null => false
    t.string   "scrumworks_id", :null => false
    t.string   "title",         :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

end
