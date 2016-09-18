class CreateBlocks < ActiveRecord::Migration
  def change
    create_table :blocks, :id => false do |t|
      t.integer  :id,      null: false, limit: 5, options: 'PRIMARY KEY'
      t.string   :witness, null: false, limit: 16
      t.integer  :txs,     null: false, limit: 3
      t.datetime :signed,  null: false

      t.index :id, unique: true
      t.index [:witness, :id]
      t.index [:signed, :id]
    end
  end
end
