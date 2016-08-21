import React                  from 'react'
import ReactDOM               from 'react-dom'
import { Post }               from './model'
import { User }               from './model'
import { MostRecentView }     from './view'

const getJson = (url) => {
  var xmlHttp = new XMLHttpRequest()
  xmlHttp.open("GET", url, false)
  xmlHttp.send(null)
  return JSON.parse(xmlHttp.responseText)
}

const getNMostRecentPosts = (n) => {
  const postsJson = getJson("/api/post/most_recent?page=0&page_size=" + n.toString())

  if (postsJson.hasOwnProperty("errors")) {
    throw "API Errors: " + postsJson.errors.map ( s => s.toString() ).toString()

  } else if (!postsJson.hasOwnProperty("results")) {
    throw "Unexpected API response: " + postsJson.toString()

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
    const { results } = postsJson
    return results.map( postJson => new Post(
      postJson.id,
      new User(postJson.author.id, postJson.author.name),
      postJson.title,
      new Date(postJson.created_millis),
      postJson.tags,
      postJson.content
    ))
  }
}

ReactDOM.render(
  <MostRecentView posts = {getNMostRecentPosts(10)} />,
  document.getElementById('app')
)
