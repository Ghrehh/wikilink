class AddFound < ActiveRecord::Migration
  def change
    add_column :searches, :found_result, :boolean, :null => false, :default => false
  end
end
