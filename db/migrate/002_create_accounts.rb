class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts, :id => false do |t|
      t.integer  :id,   null: false, limit: 5, options: 'PRIMARY KEY'
      t.string   :name, null: false, limit: 16

      t.string   :proxy,       limit: 16
      t.integer  :proxy_vests, limit: 6

      t.datetime :created, null: false
      t.datetime :active,  null: false

      t.integer :steem, null: false, limit: 6
      t.integer :sbd,   null: false, limit: 6
      t.integer :vests, null: false, limit: 6

      t.integer  :post_count, null: false, limit: 4
      t.float    :reputation, null: false

      t.text :votes_for

      t.index :id,   unique: true
      t.index :name, unique: true
      t.index :proxy
      t.index :proxy_vests

    end
  end
end
