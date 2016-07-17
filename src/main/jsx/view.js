import React                  from 'react'
import { PropTypes }          from 'react'
import { Button }             from 'react-bootstrap'
import { ButtonToolbar }      from 'react-bootstrap'
import * as Styles            from './styles'

export const MainView = function(props) {
  return (
    <div id = 'main'>
      <HeaderView />
      {props.children}
    </div>
  )
}
MainView.propTypes = {
  // Components specific to this view
  children: PropTypes.object.isRequired,
}

export const HeaderView = function(props) {
  return (
    <div id = 'header'  >
      <ButtonToolbar>
        <Button active>Posts</Button>
        <Button       >About</Button>
      </ButtonToolbar>
    </div>
  )
}

export const PostsView = function(props) {
  const { posts } = props
  return (
    <div id = 'home'>
    {posts.map(function(post) {
      return (<PostView post = {post} key = {post.id} />)
    })}
    </div>
  )
}
PostsView.propTypes = {
  // A list of Post objects
  posts: PropTypes.array.isRequired
}

export const PostView = function(props) {
  const { post } = props
  return (
    <div id = 'entry-{id}'>
      <div className = "title">{post.title}</div>
      <div className = "content">{post.content}</div>
    </div>
  )
}
PostView.propTypes = {
  // A Post object
  post: PropTypes.object.isRequired
}
