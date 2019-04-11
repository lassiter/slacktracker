class CreateUsersTrackersTable < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :slack_team_id, null: false
      t.string :slack_user_id, null: false
      t.datetime :created_at
      t.datetime :updated_at
    end
    create_table :trackers do |t|
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.datetime :created_at
      t.datetime :updated_at
    end
    add_reference :trackers, :user, index: true
  end
end
