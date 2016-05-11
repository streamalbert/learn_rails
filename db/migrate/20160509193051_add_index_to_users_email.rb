class AddIndexToUsersEmail < ActiveRecord::Migration
  def change
    # This uses a Rails method called add_index to add an index on the email column of the users table. 
    # The index by itself doesn’t enforce uniqueness, but the option unique: true does. DB level uniqueness
    # Moreover, adding this index on the email attribute fixes a potential efficiency problem by preventing 
    # a full-table scan when finding users by email address.
    add_index :users, :email, unique: true
  end
end
