export function intersperse (list, element) {
  return [].concat(...list.map(e => [element, e])).slice(1)
}
