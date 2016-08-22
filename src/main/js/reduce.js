import { Action }             from './action'
import * as Assert            from './assert'
import { BlogState }          from './state'
import { EmptyState }         from './state'
import { InitialState }       from './state'

class ReducerResult {}

const Unhandled = new ReducerResult()
class Handled extends ReducerResult {
  constructor(newState) {
    super()
    Assert.isInstanceOf(newState, BlogState)
    this.newState = newState
  }
}

class Reducer {
  reduce(state, action) {
    throw "Unimplemented"
  }
}

export const mainReducer = reducers => {
  Assert.isListOf(reducers, Reducer)

  return (state = EmptyState, action) => {
    if (state  === EmptyState) {
      return InitialState
    }

    Assert.isInstanceOf(state, BlogState)
    Assert.isInstanceOf(action, Action)

    for (reducer in reducers) {
      const result = reducer.reduce(state, action)
      Assert.isInstanceOf(result, ReducerResult)

      if (result instanceof Handled) {
        return result.newState
      }
    }

    throw `No reducers handled action: ${action}, reducers: ${reducers}`
  }
}

export class MostRecentReducer extends Reducer {
  reduce(state, action) {
    switch (action.constructor) {
      case GoToMostRecent:
        return new Handled(new MostRecentState(action.posts))
      default:
        return Unhandled
    }
  }
}
