class CreateAnalysisResult < ActiveRecord::Migration
  def change
    create_table :analysis_results do |t|
      t.text :count #json column
      t.text :username
      t.integer :most_recent_known_id, :limit => 8 # 64 bit integer
    end

    add_index :analysis_results, :username, :unique => true
  end
end
