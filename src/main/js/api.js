import $                      from 'jquery'
import { Post }               from './model'
import { User }               from './model'

export class ApiClient {
  getMostRecentPosts(pageSize, page) {
    throw "Not Implemented"
  }
}

export class RemoteApiClient extends ApiClient {

  constructor(apiUriBase) {
    super()
    this.apiUriBase = apiUriBase
  }

  getMostRecentPosts(pageSize, page = 0, timeout = RemoteApiClient.DefaultTimeoutMillis) {
    // TODO: URI path lib?
    const url = this.apiUriBase + RemoteApiClient.MostRecentPath
    return new Promise((thenF, catchF) =>
      $.ajax(url, {
        dataType: "json",
        method: "GET",
        data: { page_size: pageSize, page },
        success: (data, status, xhr) => this._parsePostsResults(data, thenF, catchF),
        error: (xhr, status, error) => catchF(error),
        timeout,
      })
    )
  }

  _parsePostsResults(postsJson, thenF, catchF) {
    // Example:
    //
    // { "errors": ["Invalid param 'b'"] }
    if (postsJson.hasOwnProperty("errors")) {
      catchF("API Errors: " + postsJson.errors.map ( s => s.toString() ).toString())

    // Server-side issue?
    } else if (!postsJson.hasOwnProperty("results")) {
      catchF("Unexpected API response: " + postsJson.toString())

    } else {
      // Example:
      //
      // { "results": [
      //   {
      //     "id": 0,
      //     "author":{
      //       "id": 0,
      //       "name": "Ben Pence"
      //     },
      //     "title": "Spring Reborn!",
      //     "created_millis": 1471202213000,
      //     "tags":["spring", "reborn"],
      //     "content": "<p></p>",
      //   },
      //   ...
      // ]}
      const posts = postsJson.results.map( postJson => new Post(
        postJson.id,
        new User(postJson.author.id, postJson.author.name),
        postJson.title,
        new Date(postJson.created_millis),
        postJson.tags,
        postJson.content
      ))

      thenF(posts)
    }
  }
}
RemoteApiClient.MostRecentPath = "/post/most_recent"
RemoteApiClient.DefaultTimeout = 1000
