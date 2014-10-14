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

ActiveRecord::Schema.define(version: 20141013233244) do

  create_table "associations", force: true do |t|
    t.integer  "point_id"
    t.integer  "finding_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "findings", force: true do |t|
    t.text     "finding"
    t.integer  "research_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "sample_def"
    t.text     "quote"
  end

  add_index "findings", ["created_at"], name: "index_findings_on_created_at"

  create_table "friendly_id_slugs", force: true do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"

  create_table "points", force: true do |t|
    t.text     "point"
    t.integer  "question_id"
    t.integer  "finding_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cached_votes_total", default: 0
    t.integer  "user_create_id"
    t.text     "point_type"
    t.integer  "cached_votes_up",    default: 0
    t.integer  "cached_votes_down",  default: 0
  end

  add_index "points", ["cached_votes_down"], name: "index_points_on_cached_votes_down"
  add_index "points", ["cached_votes_total"], name: "index_points_on_cached_votes_total"
  add_index "points", ["cached_votes_up"], name: "index_points_on_cached_votes_up"

  create_table "questions", force: true do |t|
    t.string   "question"
    t.text     "description"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cached_votes_total", default: 0
    t.integer  "user_create_id"
    t.text     "question_type"
    t.text     "answers"
    t.integer  "cached_votes_up",    default: 0
    t.integer  "cached_votes_down",  default: 0
    t.string   "slug"
  end

  add_index "questions", ["cached_votes_down"], name: "index_questions_on_cached_votes_down"
  add_index "questions", ["cached_votes_total"], name: "index_questions_on_cached_votes_total"
  add_index "questions", ["cached_votes_up"], name: "index_questions_on_cached_votes_up"
  add_index "questions", ["created_at"], name: "index_questions_on_created_at"
  add_index "questions", ["slug"], name: "index_questions_on_slug"

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
    t.integer  "user_create_id"
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
    t.string   "username"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "verdicts", force: true do |t|
    t.text     "verdict"
    t.integer  "question_id"
    t.integer  "cached_votes_total", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_create_id"
    t.text     "short"
    t.integer  "cached_votes_up",    default: 0
    t.integer  "cached_votes_down",  default: 0
  end

  add_index "verdicts", ["cached_votes_down"], name: "index_verdicts_on_cached_votes_down"
  add_index "verdicts", ["cached_votes_total"], name: "index_verdicts_on_cached_votes_total"
  add_index "verdicts", ["cached_votes_up"], name: "index_verdicts_on_cached_votes_up"

  create_table "votes", force: true do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope"
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope"

end
