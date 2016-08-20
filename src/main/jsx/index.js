import React                  from 'react'
import ReactDOM               from 'react-dom'
import { Post }               from './model'
import { User }               from './model'
import { MostRecentView }     from './view'

var posts = [
  new Post(
    "abc",
    new User(0, "ben"),
    "How I Met Your String",
    new Date(87987989),
    ["mother", "how"],
    "this is how I met her"
  ),
  new Post(
    "def",
    new User(0, "ben"),
    "How I Met Your Father",
    new Date(879879888),
    ["father", "how"],
    "this is how I met him"
  ),
]

ReactDOM.render(
  <MostRecentView posts = {posts} />,
  document.getElementById('app')
)
