defmodule TkExporter do
  require Logger
  require Retry
  alias TkExporter.Application

  @moduledoc """
  A tool to export data from Tavern-Keeper before it shuts down.
  """

  @doc """
  Exports all data for a given user ID and cookie.
  """
  def export(user_id, cookie) when is_binary(user_id) and is_binary(cookie) do
    config = Application.config()
    output_dir = config[:output_dir]
    File.mkdir_p!(output_dir)

    Logger.info("Starting export for user #{user_id}")
    
    campaigns = campaign_data(user_id)
    total_campaigns = length(campaigns)
    
    Logger.info("Found #{total_campaigns} campaigns to export")
    
    campaigns
    |> Enum.with_index(1)
    |> Enum.map(fn {campaign, index} ->
      Logger.info("[#{index}/#{total_campaigns}] Exporting Campaign #{campaign["id"]}")
      campaign_export(campaign)
    end)
  end

  defp request do
    Req.new(base_url: Application.config()[:base_url])
    |> Req.Request.put_header("accept", "application/json")
    |> Req.Request.put_header("cookie", "tavern-keeper=#{System.get_env("TK_COOKIE")}")
    |> Req.Request.put_header("X-CSRF-Token", "something")
  end

  defp campaign_export(campaign) do
    config = Application.config()
    
    c =
      %{
        id: campaign["id"],
        system_name: campaign["system_name"],
        name: campaign["name"]
      }
      |> characters_export()
      |> scenes_export()

    path = Path.join(config[:output_dir], "#{c.name}.json")
    json = Jason.encode!(c, pretty: true)
    File.write!(path, json)
    c
  end

  defp characters_export(campaign) do
    characters = campaign_character_data(campaign)
    total_characters = length(characters)
    
    Logger.info("Exporting #{total_characters} characters for campaign #{campaign.id}")
    
    characters
    |> Enum.with_index(1)
    |> Enum.map(fn {character, index} ->
      Logger.info("[#{index}/#{total_characters}] Exporting Character #{character["id"]}")
      Process.sleep(Application.config()[:sleep_delay])
      character_export(character["id"])
    end)
    |> then(fn characters -> Map.put(campaign, :characters, characters) end)
  end

  defp character_export(character_id) do
    with {:ok, data} <- retry_request(fn -> character_data(character_id) end) do
      %{
        id: data["id"],
        name: data["name"],
        concept: data["concept"],
        quote: data["quote"],
        nickname: data["nickname"],
        sheet: data["sheet"]["data"]["character"],
        bio: %{
          background: data["biography"]["background"],
          personality: data["biography"]["personality"],
          appearance: data["biography"]["appearance"]
        }
      }
    end
  end

  defp scenes_export(campaign) do
    scenes = campaign_roleplay_data(campaign)
    total_scenes = length(scenes)
    
    Logger.info("Exporting #{total_scenes} scenes for campaign #{campaign.id}")
    
    scenes
    |> Enum.with_index(1)
    |> Enum.map(fn {scene, index} ->
      Logger.info("[#{index}/#{total_scenes}] Exporting Scene #{scene["id"]}")
      Process.sleep(Application.config()[:sleep_delay])
      %{
        name: scene["name"],
        messages: scene_messages_export(scene["id"])
      }
    end)
    |> then(fn scenes -> Map.put(campaign, :scenes, scenes) end)
  end

  defp scene_messages_export(scene_id) do
    roleplay_message_data(scene_id)
    |> Enum.map(fn message ->
      %{
        content: message["content"],
        character: message["character"]["name"],
        roll: message["roll"],
        comments: if message["comment_count"] == 0 do
          []
        else
          roleplay_message_comments_data(scene_id, message["id"])
          |> Enum.map(fn comment -> 
            %{
              name: comment["user"]["name"],
              content: comment["content"]
            }
          end)
        end
      }
    end)
  end

  defp retry_request(fun) do
    config = Application.config()
    Retry.retry_while(
      with: Retry.DelayStreams.linear_backoff(config[:retry_delay], 2) |> Retry.DelayStreams.cap(config[:retry_delay] * 4) |> Stream.take(config[:max_retries]),
      rescue_only: [RuntimeError]
    ) do
      case fun.() do
        {:ok, result} -> {:halt, {:ok, result}}
        {:error, error} -> {:cont, {:error, error}}
        result -> {:halt, {:ok, result}}
      end
    end
  end

  defp campaign_data(user_id) do
    with {:ok, response} <- retry_request(fn -> 
      request()
      |> Req.get(url: "/api_v0/users/#{user_id}/campaigns")
    end) do
      response.body["campaigns"]
    end
  end

  defp campaign_character_data(campaign, options \\ []) do
    page = Keyword.get(options, :page, 1)
    data = Keyword.get(options, :data, [])

    with {:ok, response} <- retry_request(fn ->
      request()
      |> Req.get(url: "/api_v0/campaigns/#{campaign.id}/characters?page=#{page}")
    end) do
      request_data = response.body

      if request_data["page"] >= request_data["pages"] do
        data ++ request_data["characters"]
      else
        Process.sleep(Application.config()[:sleep_delay])
        campaign_character_data(campaign, [page: page + 1, data: data ++ request_data["characters"]])
      end
    end
  end

  defp campaign_roleplay_data(campaign, options \\ []) do
    page = Keyword.get(options, :page, 1)
    data = Keyword.get(options, :data, [])

    with {:ok, response} <- retry_request(fn ->
      request()
      |> Req.get(url: "/api_v0/campaigns/#{campaign.id}/roleplays?page=#{page}")
    end) do
      request_data = response.body

      if request_data["page"] >= request_data["pages"] do
        data ++ request_data["roleplays"]
      else
        Process.sleep(Application.config()[:sleep_delay])
        campaign_roleplay_data(campaign, [page: page + 1, data: data ++ request_data["roleplays"]])
      end
    end
  end

  defp roleplay_message_data(roleplay_id, options \\ []) do
    page = Keyword.get(options, :page, 1)
    data = Keyword.get(options, :data, [])

    with {:ok, response} <- retry_request(fn ->
      request()
      |> Req.get(url: "/api_v0/roleplays/#{roleplay_id}/messages?page=#{page}")
    end) do
      request_data = response.body

      if request_data["page"] >= request_data["pages"] do
        data ++ request_data["messages"]
      else
        Process.sleep(Application.config()[:sleep_delay])
        roleplay_message_data(roleplay_id, [page: page + 1, data: data ++ request_data["messages"]])
      end
    end
  end

  defp roleplay_message_comments_data(roleplay_id, message_id, options \\ []) do
    page = Keyword.get(options, :page, 1)
    data = Keyword.get(options, :data, [])

    with {:ok, response} <- retry_request(fn ->
      request()
      |> Req.get(url: "/api_v0/roleplays/#{roleplay_id}/messages/#{message_id}/comments?page=#{page}")
    end) do
      request_data = response.body

      if request_data["page"] >= request_data["pages"] do
        data ++ request_data["comments"]
      else
        Process.sleep(Application.config()[:sleep_delay])
        roleplay_message_comments_data(roleplay_id, message_id, [page: page + 1, data: data ++ request_data["comments"]])
      end
    end
  end

  defp character_data(character_id) do
    with {:ok, response} <- retry_request(fn ->
      request()
      |> Req.get(url: "/api_v0/characters/#{character_id}")
    end) do
      response.body
    end
  end
end
