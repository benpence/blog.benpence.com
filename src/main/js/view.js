import React                  from 'react'
import { intersperse }        from './util'

export const MostRecentView = function({posts}) {
  const postViews = posts.map( post => <PostView post = {post} /> )
  const children = intersperse(postViews, <div className="post-separator" />)

  return (
    <div id = 'most-recent'>
      {children}
    </div>
  )
}

export const PostView = function({post}) {
  const date = post.createdDate
  const dateString = date.getFullYear() + "-" + date.getMonth() + "-" + date.getDate()

  return (
    <div className="post">
      <p className="title">{post.title}</p>
      <p>by <a className="author">{post.author.name}</a></p>
      <p>posted on <span className="date">{dateString}</span></p>
      <p>tags: {post.tags.map (tag =>
        <a className="tag">{tag}</a>
      )}</p>
      <div className="content" dangerouslySetInnerHTML={ {__html: post.content } } />
    </div>
  )
}
