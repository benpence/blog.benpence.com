export class Action {}

export class GoToMostRecent extends Action {
  construction(posts) {
    this.posts = posts
  }
}
