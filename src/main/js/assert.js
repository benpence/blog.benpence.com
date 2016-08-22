const AssertionError = (value, type) =>
  `AssertionError: Expected type ${type}. Got ${value}`
const ListAssertionError = (value, type) => AssertionError(value, `[${type}]`)

const _instanceOf = (item, type) => item instanceof type

export const isInstanceOf = (value, type) => {
  if (!(_instanceOf(value, type))) throw AssertionError(value, type)
}

export const isListOf = (list, type) => {
  if (list == null || !(typeof list[Symbol.iterator] === 'function')) {
    throw ListAssertionError(list, type)
  }

  list.forEach( item => {
    if (!_instanceOf(item, type)) {
      throw ListAssertionError(list, type)
    }
  })
}
