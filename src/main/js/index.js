import React                  from 'react'
import ReactDOM               from 'react-dom'
import { createStore }        from 'redux'
import { RemoteApiClient }    from './api'
import { GoToMostRecent }     from './action'
import { mainReducer }        from './reduce'
import { MostRecentReducer }  from './reduce'
import { MostRecentView }     from './view'

const store = createStore(mainReducer([
  new MostRecentReducer,
]))
store.subscribe(() => {
  const posts = store.getState().posts
  ReactDOM.render(
    <MostRecentView posts = {posts} />,
    document.getElementById('app')
  )
})

const client = new RemoteApiClient("/api")
client
  .getMostRecentPosts(10)
  .then( posts => store.dispatch(new GoToMostRecent(posts)) )
  .catch( t => { throw t })
