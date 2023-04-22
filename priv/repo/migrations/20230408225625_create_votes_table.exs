defmodule DertGg.Repo.Migrations.CreateVotesTable do
  use Ecto.Migration

  def change do
    create table(:votes, primary_key: false) do
      add :user_id, references(:users), null: false, primary_key: true
      add :entry_id, :bigint, null: false, primary_key: true
      add :topic_id, :bigint, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
