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

ActiveRecord::Schema.define(version: 5) do

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
    t.integer  "id",      limit: 8,  null: false
    t.string   "witness", limit: 16, null: false
    t.integer  "txs",     limit: 3,  null: false
    t.datetime "signed",             null: false
  end

  add_index "blocks", ["id"], name: "index_blocks_on_id", unique: true, using: :btree
  add_index "blocks", ["signed", "id"], name: "index_blocks_on_signed_and_id", using: :btree
  add_index "blocks", ["witness", "id"], name: "index_blocks_on_witness_and_id", using: :btree

  create_table "post_ids", force: :cascade do |t|
    t.integer "parent_id", limit: 4,   null: false
    t.integer "block_id",  limit: 4,   null: false
    t.string  "author",    limit: 16,  null: false
    t.string  "permlink",  limit: 255, null: false
    t.string  "category",  limit: 255, null: false
  end

  add_index "post_ids", ["author", "permlink"], name: "index_post_ids_on_author_and_permlink", unique: true, using: :btree
  add_index "post_ids", ["block_id"], name: "index_post_ids_on_block_id", using: :btree
  add_index "post_ids", ["category"], name: "index_post_ids_on_category", using: :btree

  create_table "posts", id: false, force: :cascade do |t|
    t.integer  "id",                         limit: 8,        null: false
    t.integer  "parent_id",                  limit: 4,        null: false
    t.integer  "children",                   limit: 2,        null: false
    t.integer  "block",                      limit: 4,        null: false
    t.string   "author",                     limit: 16,       null: false
    t.string   "permlink",                   limit: 255,      null: false
    t.string   "category",                   limit: 255,      null: false
    t.text     "title",                      limit: 16777215, null: false
    t.text     "body",                       limit: 16777215, null: false
    t.text     "json",                       limit: 16777215, null: false
    t.datetime "created",                                     null: false
    t.datetime "updated",                                     null: false
    t.datetime "active",                                      null: false
    t.datetime "paid"
    t.datetime "cashout"
    t.integer  "net_rshares",                limit: 4,        null: false
    t.integer  "vote_rshares",               limit: 4,        null: false
    t.integer  "children_abs_rshares",       limit: 4,        null: false
    t.float    "total_vote_weight",          limit: 53,       null: false
    t.integer  "total_payout_value",         limit: 8,        null: false
    t.integer  "curator_payout_value",       limit: 8,        null: false
    t.integer  "pending_payout_value",       limit: 8,        null: false
    t.integer  "total_pending_payout_value", limit: 8,        null: false
  end

  add_index "posts", ["created"], name: "index_posts_on_created", using: :btree
  add_index "posts", ["id"], name: "index_posts_on_id", unique: true, using: :btree

  create_table "votes", id: false, force: :cascade do |t|
    t.integer  "voter_id", limit: 4
    t.integer  "post_id",  limit: 4
    t.integer  "weight",   limit: 3
    t.datetime "created"
  end

  add_index "votes", ["post_id", "created", "voter_id"], name: "index_votes_on_post_id_and_created_and_voter_id", unique: true, using: :btree

end
