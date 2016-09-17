class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts, :id => false do |t|
      t.integer  :id, null: false, limit: 5, options: 'PRIMARY KEY'
      t.string   :name, limit: 16

      t.string   :proxy, limit: 16
      t.integer  :proxy_vests, limit: 6

      t.datetime :created
      t.datetime :active

      t.integer :steem, limit: 6
      t.integer :sbd,   limit: 6
      t.integer :vests, limit: 6

      t.integer  :post_count, limit: 4
      t.float    :reputation

      t.text :votes_for

      t.index :id,   unique: true
      t.index :name, unique: true

    end
  end
end
