package com.benpence.blog.store

import com.benpence.blog.model.{Cookie, Login, UserId}
import com.twitter.storehaus.ConcurrentHashMapStore
import com.twitter.storehaus.Store
import com.twitter.util.Future

trait LoginStore extends Store[Cookie, Login]
class MemoryLoginStore extends ConcurrentHashMapStore[Cookie, Login] with LoginStore
