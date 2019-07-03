defmodule ChangelogWeb.Admin.SearchView do
  use ChangelogWeb, :admin_view

  alias Changelog.{EpisodeSponsor, Faker, NewsItem, Repo}
  alias ChangelogWeb.Endpoint
  alias ChangelogWeb.Admin.{TopicView, EpisodeView, NewsItemView, NewsSourceView,
                            PersonView, PodcastView, PostView, SponsorView}

  @limit 3

  def render("all.json", _params = %{results: results, query: query}) do
    response = %{results: %{
      topics: %{name: "Topics", results: process_results(results.topics, &topic_result/1)},
      episodes: %{name: "Episodes", results: process_results(results.episodes, &episode_result/1)},
      news_items: %{name: "News", results: process_results(results.news_items, &news_item_result/1)},
      news_sources: %{name: "Sources", results: process_results(results.news_sources, &news_source_result/1)},
      people: %{name: "People", results: process_results(results.people, &person_result/1)},
      podcasts: %{name: "Podcasts", results: process_results(results.podcasts, &podcast_result/1)},
      posts: %{name: "Posts", results: process_results(results.posts, &post_result/1)},
      sponsors: %{name: "Sponsors", results: process_results(results.sponsors, &sponsor_result/1)}}}

    counts = Enum.map(results, fn({_type, results}) -> Enum.count(results) end)
    if Enum.any?(counts, fn(count) -> count > @limit end) do
      Map.put(response, :action, %{url: "/admin/search?q=#{query}", text: "View all #{Enum.sum(counts)} results"})
    else
      response
    end
  end

  def render(json_template, _params = %{results: results, query: _query}) do
    process_fn = case json_template do
      "news_item.json" -> &news_item_result/1
      "news_source.json" -> &news_source_result/1
      "person.json" -> &person_result/1
      "podcast.json" -> &podcast_result/1
      "sponsor.json" -> &sponsor_result/1
      "topic.json" -> &topic_result/1
    end

    %{results: Enum.map(results, process_fn)}
  end

  defp process_results(records, process_fn) do
    records
    |> Enum.take(@limit)
    |> Enum.map(process_fn)
  end

  defp episode_result(episode) do
    %{id: episode.id,
      title: EpisodeView.numbered_title(episode),
      url: admin_podcast_episode_path(Endpoint, :show, episode.podcast.slug, episode.slug)}
  end

  defp news_item_result(news_item) do
    %{id: news_item.id,
      title: news_item.headline,
      url: admin_news_item_path(Endpoint, :edit, news_item)}
  end

  defp news_source_result(news_source) do
    %{id: news_source.id,
      title: news_source.name,
      image: NewsSourceView.icon_url(news_source),
      url: admin_news_source_path(Endpoint, :edit, news_source)}
  end

  defp person_result(person) do
    {title, description} = if Enum.member?(Faker.names(), person.name) do
      {person.email, "(profile incomplete)"}
    else
      {person.name,"(#{person.handle})"}
    end

    %{id: person.id,
      title: title,
      description: description,
      image: PersonView.avatar_url(person),
      url: admin_person_path(Endpoint, :edit, person)}
  end

  defp podcast_result(podcast) do
    %{id: podcast.id,
      title: podcast.name,
      image: PodcastView.cover_url(podcast, :small),
      url: admin_podcast_path(Endpoint, :edit, podcast.slug)}
  end

  defp post_result(post) do
    %{id: post.id,
      title: post.title,
      url: admin_post_path(Endpoint, :edit, post)}
  end

  defp sponsor_result(sponsor) do
    latest =
      sponsor
      |> Ecto.assoc(:episode_sponsors)
      |> EpisodeSponsor.newest_first
      |> Ecto.Query.first
      |> Repo.one

    extras = if latest do
       %{title: latest.title,
         link_url: latest.link_url,
         description: latest.description}
    else
      %{title: sponsor.name,
        link_url: sponsor.website,
        description: sponsor.description}
    end

    %{id: sponsor.id,
      title: sponsor.name,
      image: SponsorView.avatar_url(sponsor, :small),
      url: admin_sponsor_path(Endpoint, :edit, sponsor),
      extras: extras}
  end

  defp topic_result(topic) do
    %{id: topic.id,
      title: topic.name,
      image: TopicView.icon_url(topic),
      url: admin_topic_path(Endpoint, :edit, topic.slug)}
  end
end
