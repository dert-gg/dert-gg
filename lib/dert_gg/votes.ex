defmodule DertGg.Votes do
  @moduledoc """
  The Votes context.
  """

  alias DertGg.Repo
  alias DertGg.Votes.Vote

  import Ecto.Query

  def create_vote!(params) do
    %Vote{}
    |> Vote.changeset(params)
    |> Repo.insert!()
  end

  def delete_vote!(params) do
    Vote
    |> Repo.get_by(params)
    |> Repo.delete!()
  end

  def aggregate_votes(entry_id) do
    Vote
    |> where(entry_id: ^entry_id)
    |> Repo.aggregate(:count)
  end

  # This could instead return a map, which would
  # make things easier on the JS side and fast access.
  #
  # nil means the user has not logged in so it's an anonymous user.
  # In that case we still want to show vote counts to people
  def vote_counts_by_topic_id(topic_id, user_id \\ nil) do
    has_voted =
      if user_id do
        dynamic([v], max(fragment("CASE WHEN user_id = ? THEN 1 ELSE 0 END", ^user_id)) == 1)
      else
        dynamic([v], false)
      end

    Vote
    |> where(topic_id: ^topic_id)
    |> group_by([v], v.entry_id)
    |> select([v], %{v.entry_id => count(v.entry_id)})
    # This dynamically changes the query based on whether the user is logged in or not.
    |> select_merge([v], ^%{has_voted: has_voted})
    |> Repo.all()
  end
end
