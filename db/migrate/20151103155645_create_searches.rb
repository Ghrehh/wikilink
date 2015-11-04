class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.string :start_url
      t.string :search_phrase
      t.boolean :failed, :null => false, :default => false
      t.boolean :finished, :null => false, :default => false
      t.timestamps null: false
    end
  end
end
