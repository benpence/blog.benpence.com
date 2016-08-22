import Immutable              from 'immutable'

export class User {
  constructor(id, name) {
    this.id = id
    this.name = name
  }
}

export class Post {
  constructor(id, author, title, createdDate, tags, content) {
    this.id = id
    this.author = author
    this.title = title
    this.createdDate = createdDate
    this.tags = Immutable.Set(tags)
    this.content = content
  }
}
