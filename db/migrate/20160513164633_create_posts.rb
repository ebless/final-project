class CreatePosts < ActiveRecord::Migration
  def change
  	create_table :posts do |t|
  		t.belongs_to :user

  		t.text :title
  		t.text :content

  		t.timestamps
  	end
  end
end
