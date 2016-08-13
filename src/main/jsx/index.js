import { Post }               from './model'
import { MainRoute }          from './route'
import { PostsRoute }         from './route'
import State                  from './state'
import React                  from 'react'
import { PropTypes }          from 'react'
import ReactDOM               from 'react-dom'
import ReactRouter            from 'react-router'
import { hashHistory }        from 'react-router'
import { Router }             from 'react-router'
import { Route }              from 'react-router'
import { IndexRoute }         from 'react-router'
import Redux                  from 'redux'

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

//const routes = (
//  <Router history = {hashHistory} >
//    <Route path = '/' component = {MainRoute} >
//      <IndexRoute component = {PostsRoute}
//        posts = {posts}
//      />
//    </Route>
//  </Router>
//)
//
//const render = () => {
//  ReactDOM.render(
//    routes,
//    document.getElementById('app')
//  )
//}

const store = Redux.createStore(State.reducer)
store.subscribe(render)
render()
