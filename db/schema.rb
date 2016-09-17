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

ActiveRecord::Schema.define(version: 2) do

  create_table "accounts", id: false, force: :cascade do |t|
    t.integer  "id",          limit: 8,     null: false
    t.string   "name",        limit: 16
    t.string   "proxy",       limit: 16
    t.integer  "proxy_vests", limit: 8
    t.datetime "created"
    t.datetime "active"
    t.integer  "steem",       limit: 8
    t.integer  "sbd",         limit: 8
    t.integer  "vests",       limit: 8
    t.integer  "post_count",  limit: 4
    t.float    "reputation",  limit: 24
    t.text     "votes_for",   limit: 65535
  end

  add_index "accounts", ["id"], name: "index_accounts_on_id", unique: true, using: :btree
  add_index "accounts", ["name"], name: "index_accounts_on_name", unique: true, using: :btree

  create_table "blocks", id: false, force: :cascade do |t|
    t.integer  "id",        limit: 8,  null: false
    t.string   "witness",   limit: 16
    t.integer  "txs",       limit: 3
    t.datetime "signed_at"
  end

  add_index "blocks", ["id"], name: "index_blocks_on_id", unique: true, using: :btree
  add_index "blocks", ["signed_at", "id"], name: "index_blocks_on_signed_at_and_id", using: :btree
  add_index "blocks", ["witness", "id"], name: "index_blocks_on_witness_and_id", using: :btree

end
