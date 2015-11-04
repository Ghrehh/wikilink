class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :url
      t.integer :search_id
      t.timestamps null: false
    end
  end
end
