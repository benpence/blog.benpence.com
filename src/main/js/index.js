import React                  from 'react'
import ReactDOM               from 'react-dom'
import { RemoteApiClient }    from './api'
import { MostRecentView }     from './view'

const client = new RemoteApiClient("/api")

client
  .getMostRecentPosts(10)
  .then( posts => 
    ReactDOM.render(
      <MostRecentView posts = {posts} />,
      document.getElementById('app')
    )
  )
  .catch( t => { throw t })
