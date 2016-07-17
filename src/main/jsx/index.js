import { Post }               from './model'
import { MainRoute }          from './route'
import { PostsRoute }         from './route'
import React                  from 'react'
import { PropTypes }          from 'react'
import ReactDOM               from 'react-dom'
import ReactRouter            from 'react-router'
import { hashHistory }        from 'react-router'
import { Router }             from 'react-router'
import { Route }              from 'react-router'
import { IndexRoute }         from 'react-router'

var posts = [
  new Post(
    "abc",
    "How I Met Your String",
    new Date(87987989),
    ["mother", "how"],
    "this is how I met her"
  ),
  new Post(
    "def",
    "How I Met Your Father",
    new Date(879879888),
    ["father", "how"],
    "this is how I met him"
  ),
]

var routes = (
  <Router history = {hashHistory} >
    <Route path = '/' component = {MainRoute} >
      <IndexRoute component = {PostsRoute}
        posts = {posts}
      />
    </Route>
  </Router>
)

ReactDOM.render(
  routes,
  document.getElementById('app')
)
