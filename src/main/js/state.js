export class BlogState {}

export const EmptyState = new BlogState()
export const InitialState = new BlogState()

export class MostRecentState extends BlogState {
  constructor(pageSize, posts = []) {
    super()
    this.pageSize = pageSize
    this.posts = posts
  }
}
