defmodule DertGgWeb.RoomChannel do
  use DertGgWeb, :channel

  alias DertGg.Accounts.JwtToken
  alias DertGg.Votes

  @impl true
  def join("room:lobby", _payload, socket) do
      {:ok, socket}
  end

  @impl true
  def join("room:" <> room_id, %{"jwt" => jwt}, socket) when is_nil(jwt) or jwt == "" do
    Sentry.Context.set_tags_context(%{room_id: room_id})
    vote_counts = Votes.vote_counts_by_topic_id(room_id)

    {:ok, vote_counts, socket}
  end

  @impl true
  def join("room:" <> room_id, %{"jwt" => jwt}, socket) when is_binary(jwt) do
    Sentry.Context.set_tags_context(%{room_id: room_id})

    case JwtToken.verify_and_validate(jwt) do
      {:ok, claims} ->
        user_id = claims["user_id"]
        Sentry.Context.set_user_context(%{id: user_id})
        vote_counts = Votes.vote_counts_by_topic_id(room_id, user_id)

        {:ok, vote_counts, socket}

      {:error, reason} ->
        Sentry.capture_message("Invalid JWT token", extra: %{reason: reason})
        vote_counts = Votes.vote_counts_by_topic_id(room_id)

        {:ok, vote_counts, socket}
    end
  end

  @impl true
  def join("room:" <> room_id, _, socket) do
    Sentry.Context.set_tags_context(%{room_id: room_id})
    vote_counts = Votes.vote_counts_by_topic_id(room_id)

    {:ok, vote_counts, socket}
  end

  ################# UPVOTE #################

  @impl true
  def handle_in("upvote", %{"jwt" => ""}, socket) do
    {:reply, :unauthorized, socket}
  end

  @impl true
  def handle_in("upvote", %{"jwt" => jwt}, socket) when not is_binary(jwt) do
    {:reply, :unauthorized, socket}
  end


  @impl true
  def handle_in("upvote", %{"jwt" => jwt} = payload, socket) do
    case JwtToken.verify_and_validate(jwt) do
      {:ok, claims} ->
        entry_id = payload["entry_id"]
        topic_id = get_topic_id(socket.topic)
        user_id = claims["user_id"]

        Votes.create_vote!(%{
          entry_id: entry_id,
          topic_id: topic_id,
          user_id: user_id
        })

        broadcast(socket, "vote_count_changed", %{
          entry_id: entry_id,
          vote_count: Votes.aggregate_votes(entry_id)
        })

        {:reply, :ok, socket}

      {:error, reason} ->
        Sentry.capture_message("Invalid JWT token", extra: %{reason: reason})
        {:reply, :unauthorized, socket}
    end
  end

  @impl true
  def handle_in("upvote", _, socket) do
    {:reply, :unauthorized, socket}
  end

  ################# UNVOTE #################

  @impl true
  def handle_in("unvote", %{"jwt" => ""}, socket) do
    {:reply, :unauthorized, socket}
  end

  @impl true
  def handle_in("unvote", %{"jwt" => jwt}, socket) when not is_binary(jwt) do
    {:reply, :unauthorized, socket}
  end

  @impl true
  def handle_in("unvote", %{"jwt" => jwt} = payload, socket) do
    case JwtToken.verify_and_validate(jwt) do
      {:ok, claims} ->
        entry_id = payload["entry_id"]
        user_id = claims["user_id"]

        Votes.delete_vote!(%{entry_id: entry_id, user_id: user_id})

        broadcast(socket, "vote_count_changed", %{
          entry_id: entry_id,
          vote_count: Votes.aggregate_votes(entry_id)
        })

        {:reply, :ok, socket}

      {:error, reason} ->
        Sentry.capture_message("Invalid JWT token", extra: %{reason: reason})
        {:reply, :unauthorized, socket}
    end
  end

  @impl true
  def handle_in("unvote", _, socket) do
    {:reply, :unauthorized, socket}
  end

  @impl true
  def terminate(reason, socket) do
    IO.puts("RoomChannel terminated: #{inspect(reason)}")
    IO.puts("\tSocket: #{inspect(socket)}")
  end

  defp get_topic_id("room:" <> topic_id) do
    topic_id
  end
end
