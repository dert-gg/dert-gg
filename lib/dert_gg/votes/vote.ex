defmodule DertGg.Votes.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "votes" do
    belongs_to :user, DertGg.Accounts.User, primary_key: true

    field :entry_id, :integer, primary_key: true
    field :topic_id, :integer

    timestamps(type: :utc_datetime)
  end

  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:entry_id, :user_id, :topic_id])
    |> foreign_key_constraint(:user_id)
    |> validate_required([:entry_id, :user_id, :topic_id])
    |> unique_constraint([:entry_id, :user_id], name: "votes_pkey")
  end
end

# Most of the timie I'll have the ID of the entry and the user name any way
