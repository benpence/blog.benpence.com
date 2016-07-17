import React                  from 'react'
import { PropTypes }          from 'react'
import { HeaderButtons }      from './view'
import { MainView }           from './view'
import { PostsView }          from './view'

export var MainRoute = function(props) {
  return (
    <MainView
      children = {props.children}
    />
  )
}
MainRoute.propTypes = {
  route: PropTypes.object.isRequired
}
    
export var PostsRoute = function(props) {
  const { posts } = props.route
  return <PostsView posts = {posts} />
}
PostsRoute.propTypes = {
  route: PropTypes.object.isRequired
}
