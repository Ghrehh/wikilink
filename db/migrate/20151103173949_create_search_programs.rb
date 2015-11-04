class CreateSearchPrograms < ActiveRecord::Migration
  def change
    create_table :search_programs do |t|

      t.timestamps null: false
    end
  end
end
