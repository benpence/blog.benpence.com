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
    this.tags = tags
    this.content = content
  }
}
