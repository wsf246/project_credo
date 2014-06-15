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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140613230538) do

  create_table "associations", force: true do |t|
    t.integer  "point_id"
    t.integer  "finding_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "debates", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.text     "notes"
    t.text     "verdict"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "debates", ["created_at"], name: "index_debates_on_created_at"

  create_table "findings", force: true do |t|
    t.text     "finding"
    t.integer  "research_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "sample_def"
    t.text     "quote"
  end

  add_index "findings", ["created_at"], name: "index_findings_on_created_at"

  create_table "points", force: true do |t|
    t.text     "point"
    t.boolean  "for_against"
    t.integer  "debate_id"
    t.integer  "finding_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "researches", force: true do |t|
    t.string   "study_type"
    t.string   "authors"
    t.text     "title"
    t.string   "journal"
    t.date     "date_of_publication"
    t.text     "dropouts"
    t.boolean  "retracted"
    t.boolean  "peer_reviewed"
    t.boolean  "replicated"
    t.string   "version"
    t.text     "funding"
    t.float    "funding_bias"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "single_blinded"
    t.boolean  "double_blinded"
    t.boolean  "randomized"
    t.boolean  "controlled_against_placebo"
    t.boolean  "controlled_against_best_alt"
    t.float    "score"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
